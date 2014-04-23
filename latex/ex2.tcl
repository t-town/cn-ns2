#Create simulator
set ns [new Simulator]
#Trace files + log files
set tf [open /tmp/example.out.tr w]
$ns trace-all $tf
set nf [open /tmp/example.out.nam w]
$ns namtrace-all $nf
set lf [open /tmp/example.out.log w]
set sf [open /tmp/example.out.fs w]

#Finish procedure: flushes all simulator data to file
proc finish {} {
    #finalise trace files
    global ns nf tf lf sf
    $ns flush-trace
    close $tf
    close $nf
    close $lf
    close $sf

    #call nam visualiser
    exec nam /tmp/example.out.nam &
    exit 0
}

#Define Colors
$ns color 1 Blue
$ns color 7 Red

#Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]


#Create links between nodes
$ns duplex-link $n0 $n2 10Mb 10ms DropTail
$ns duplex-link $n4 $n0 10Mb 10ms DropTail
$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n1 $n3 10Mb 10ms DropTail
$ns duplex-link $n1 $n5 10Mb 10ms DropTail

$ns queue-limit $n0 $n1 20

#Node orientation
$ns duplex-link-op $n2 $n0 orient right-down
$ns duplex-link-op $n4 $n0 orient right-up

$ns duplex-link-op $n0 $n1 orient right

$ns duplex-link-op $n1 $n3 orient right-up
$ns duplex-link-op $n1 $n5 orient right-down

######Long lasting ftp connection:#######
# TCP Connection
set tcp3 [new Agent/TCP/Reno]
$ns attach-agent $n3 $tcp3
set sink2 [new Agent/TCPSink]
$ns attach-agent $n2 $sink2
$ns connect $tcp3 $sink2
$tcp3 set fid_ 1
$tcp3 set window_ 80
# Ftp Application
set ftp32 [new Application/FTP]
$ftp32 attach-agent $tcp3

#Array with the times of departure
set time(0) 5
set time(1) 10
set time(2) 15
#Number of requests per burst
set nrRequests 40

#TCP Sources, destinations, connections
foreach {key value} [array get time] {
    for {set i 1} {$i <= $nrRequests} {incr i} {
        set tcpsrc($key,$i) [new Agent/TCP]
        set tcp_sink($key,$i) [new Agent/TCPSink]
        $tcpsrc($key,$i) set window_ 80
        $ns attach-agent $n5 $tcpsrc($key,$i)
        $ns attach-agent $n4 $tcp_sink($key,$i)
        $ns connect $tcpsrc($key,$i) $tcp_sink($key,$i)
        set ftp($key,$i) [$tcpsrc($key,$i) attach-source FTP]
    }
}

#Create  random generators:
set rng1 [new RNG]
$rng1 next-substream
$rng1 next-substream
set rng2 [new RNG]
$rng2 next-substream
#Random inter-send times of tcp transfer
set RV [new RandomVariable/Exponential]
$RV set avg_ 0.05
$RV use-rng $rng1
#Random size of files to transmit
set RVsize [new RandomVariable/Pareto]
$RVsize set avg_ 150000
$RVsize set shape_ 1.5
$RVsize use-rng $rng2

#schedule events here (example)
#setting up number of request
foreach {key value} [array get time] {
    set t $value
    for {set i 1} {$i<= $nrRequests} {incr i} {
        #Set the beginning time of next transfer.
        set t [expr $t + [$RV value]]
        set size [expr [$RVsize value]]
        $ns at $t "$ftp($key,$i) send $size"
        puts $sf "$t $size"
        }
}

proc writelog {} {
   global ns lf tcp3
   set rate 0.2
   set now [$ns now]
   set cwnd [$tcp3 set cwnd_]
   set sst [$tcp3 set ssthresh_]
   puts $lf "$now $cwnd $sst"
   $ns at [expr $now+$rate]  "writelog"
}

$ns at 0.0 "writelog"
$ns at 0.1 "$ftp32 start"
$ns at 60 "finish"

#finally execute the simulator
$ns run
