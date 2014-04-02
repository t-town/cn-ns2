#Create simulator
set ns [new Simulator]
#trace files: nam and tr
set tf [open /tmp/example.out.tr w]
$ns trace-all $tf

set nf [open /tmp/example.out.nam w]
$ns namtrace-all $nf
# finish procedure: flushes all simulator data to file

$ns color 1 Blue
$ns color 2 Red

proc finish {} {
    #finalise trace files
    global ns nf tf
    $ns flush-trace
    close $tf
    close $nf

    #call nam visualiser
    exec nam /tmp/example.out.nam &
    exit 0
}

#Create three nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

#Create links between nodes (example)
$ns duplex-link $n1 $n2 100Mb 0.2ms DropTail
$ns duplex-link $n0 $n2 100Mb 0.2ms DropTail
$ns duplex-link $n2 $n3 100Mb 0.2ms DropTail
$ns simplex-link $n3 $n4 100Mb 0.2ms DropTail
$ns simplex-link $n4 $n3 100Mb 0.2ms DropTail
$ns duplex-link $n4 $n5 100Mb 0.3ms DropTail
$ns duplex-link $n5 $n6 100Mb 0.3ms DropTail
$ns duplex-link $n5 $n7 100Mb 0.3ms DropTail

#Node orientation
$ns duplex-link-op $n1 $n2 orient right-down
$ns duplex-link-op $n0 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

$ns duplex-link-op $n5 $n6 orient right-up
$ns duplex-link-op $n5 $n7 orient right-down
$ns duplex-link-op $n4 $n5 orient right

#####################
# Place other simulation code here: #
#udp/tcp connections #
#applications #
#... #
#####################

############
#Downloader#
############
# TCP Connection
set tcp6 [new Agent/TCP]
$ns attach-agent $n6 $tcp6
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1
$ns connect $tcp6 $sink1
$tcp6 set fid_ 1
$tcp6 set window_ 80
# Ftp Application
set ftp61 [new Application/FTP]
$ftp61 attach-agent $tcp6

##########
#Uploader#
##########
# UDP Connection
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
set null7 [new Agent/Null]
$ns attach-agent $n7 $null7
$ns connect $udp0 $null7
$udp0 set fid_ 2
# CBR Application
set cbr07 [new Application/Traffic/CBR]
$cbr07 attach-agent $udp0
$cbr07 set packetSize_ 1500

$cbr07 set random_ false

#schedule events here (example)

$ns at 0.01 "$cbr07 start"
$ns at 6.0 "$cbr07 stop"

$ns at 19.71 "finish"
#finally execute the simulator
$ns run
