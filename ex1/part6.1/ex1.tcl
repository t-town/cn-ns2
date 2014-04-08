#Create simulator
set ns [new Simulator]
#trace files: nam and tr
set tf [open /tmp/example.out.tr w]
$ns trace-all $tf

set nf [open /tmp/example.out.nam w]
$ns namtrace-all $nf
# finish procedure: flushes all simulator data to file

$ns color 1 Aqua
$ns color 2 BlueViolet
$ns color 3 Brown
$ns color 4 Crimson
$ns color 5 DarkGreen
$ns color 6 Black
$ns color 7 DarkGray
$ns color 8 Red
$ns color 9 Blue
$ns color 10 Yellow
$ns color 11 Teal
$ns color 12 Sienna
$ns color 13 Salmon
$ns color 14 Purple
$ns color 15 Peru
$ns color 16 Navy
$ns color 17 Orange
$ns color 18 SlateBlue
$ns color 19 SeaGreen
$ns color 20 Indigo


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
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

#Create links between nodes (example)
$ns simplex-link $n3 $n4 2Mb 0.2ms DropTail
$ns simplex-link $n4 $n3 40Mb 0.2ms DropTail
$ns duplex-link $n4 $n5 100Mb 0.3ms DropTail
$ns duplex-link $n5 $n6 100Mb 0.3ms DropTail
$ns duplex-link $n5 $n7 100Mb 0.3ms DropTail

for {set i 1} {$i <= 5} {incr i} {
    set nodes($i) [$ns node]
    $ns duplex-link $nodes($i) $n3 10Mb 0.2ms DropTail
}

#####################
# Place other simulation code here: #
#udp/tcp connections #
#applications #
#... #
#####################

foreach {key value} [array get nodes] {
    ############
    #Downloader#
    ############
    # TCP Connection
    set tcpsrc($key) [new Agent/TCP]
    set tcp_sink($key) [new Agent/TCPSink]
    $ns attach-agent $n6 $tcpsrc($key)
    $ns attach-agent $nodes($key) $tcp_sink($key)
    $ns connect $tcpsrc($key) $tcp_sink($key)
    set ftp($key) [new Application/FTP]
    # Ftp Application
    $ftp($key) attach-agent $tcpsrc($key)
    $tcpsrc($key) set fid_ $key
    $ns at 0.1 "$ftp($key) start"
    $ns at 9.9 "$ftp($key) stop"
    $tcpsrc($key) set fid_ $key
    $tcpsrc($key) set window_ 80
    
    ##########
    #Uploader#
    ##########
    # UDP Connection
    set udp($key) [new Agent/UDP]
    $ns attach-agent $nodes($key) $udp($key)
    set null($key) [new Agent/UDP]
    $ns attach-agent $n7 $null($key)
    $ns connect $udp($key) $null($key)
    set cbr($key) [new Application/Traffic/CBR]
    # CBR Application
    $cbr($key) attach-agent $udp($key)
    $cbr($key) set packetSize_ 1500
    $cbr($key) set random_ false
    $ns at 3.0 "$cbr($key) start"
    $ns at 6.0 "$cbr($key) stop"
    $udp($key) set fid_ [expr $key + 10]
}

$ns at 19.71 "finish"
#finally execute the simulator
$ns run
