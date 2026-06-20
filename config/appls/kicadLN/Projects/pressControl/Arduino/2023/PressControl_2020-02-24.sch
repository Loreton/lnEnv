EESchema Schematic File Version 4
LIBS:PressControl-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Allarme per pompa cisterna"
Date "2020-02-16"
Rev "1.1"
Comp ""
Comment1 ""
Comment2 "Esaurito un determinato tempo Arduino provvede direttamente a spegnere la pompa"
Comment3 "Il tutto prosegue fino a che la pompa si spegne"
Comment4 "Quando la pompa si accende Arduino provvede ad emettere dei suoni "
$EndDescr
$Comp
L MCU_Module:Arduino_Nano_v3.x A?
U 1 1 5DEB7096
P 5750 1950
F 0 "A?" H 5750 864 50  0001 C CNN
F 1 "Arduino_Nano_v3.x" V 5750 1800 50  0000 C CNN
F 2 "Module:Arduino_Nano" H 5900 1000 50  0001 L CNN
F 3 "http://www.mouser.com/pdfdocs/Gravitech_Arduino_Nano3_0.pdf" H 5750 950 50  0001 C CNN
	1    5750 1950
	1    0    0    -1  
$EndComp
$Comp
L Device:R_US R?
U 1 1 5DEB74D1
P 4450 2850
F 0 "R?" H 4518 2896 50  0001 L CNN
F 1 "470" H 4518 2805 50  0000 L CNN
F 2 "" V 4490 2840 50  0001 C CNN
F 3 "~" H 4450 2850 50  0001 C CNN
	1    4450 2850
	1    0    0    -1  
$EndComp
$Comp
L Device:LED_ALT D?
U 1 1 5DEB73CD
P 4450 3200
F 0 "D?" V 4488 3082 50  0001 R CNN
F 1 "BlinkingLED" V 4397 3082 50  0000 R CNN
F 2 "" H 4450 3200 50  0001 C CNN
F 3 "~" H 4450 3200 50  0001 C CNN
	1    4450 3200
	0    -1   -1   0   
$EndComp
$Comp
L Device:Buzzer BZ?
U 1 1 5DEBAA3F
P 4050 2850
F 0 "BZ?" H 4100 2850 50  0001 C CNN
F 1 "Passive Buzzer" H 4050 2600 50  0000 C CNN
F 2 "" V 4025 2950 50  0001 C CNN
F 3 "~" V 4025 2950 50  0001 C CNN
	1    4050 2850
	-1   0    0    -1  
$EndComp
$Comp
L LnConnectors:CONN_02 J?
U 1 1 5DEBCAE0
P 7100 1300
F 0 "J?" V 7103 1628 60  0001 L CNN
F 1 "220V" V 7000 1400 60  0000 L CNN
F 2 "" H 7100 1300 60  0000 C CNN
F 3 "" H 7100 1300 60  0000 C CNN
	1    7100 1300
	1    0    0    -1  
$EndComp
Wire Wire Line
	4450 3000 4450 3050
Wire Notes Line
	10050 3300 10050 3600
Wire Notes Line
	10050 3600 10950 3600
Wire Notes Line
	10950 3600 10950 3300
Wire Notes Line
	10950 3300 10050 3300
Text Notes 10250 3500 0    50   ~ 0
PressControl
Wire Notes Line
	10050 4400 10050 4700
Wire Notes Line
	10050 4700 10950 4700
Wire Notes Line
	10950 4700 10950 4400
Wire Notes Line
	10950 4400 10050 4400
Text Notes 10250 4600 0    50   ~ 0
Pump
Wire Wire Line
	4150 2950 4150 3400
Wire Wire Line
	4450 3350 4450 3400
Text Label 4800 2550 0    50   ~ 0
Buzzer
Text Label 4800 2650 0    50   ~ 0
BlinkingLED
Wire Wire Line
	4150 2750 4150 2550
$Comp
L power:GND #PWR0101
U 1 1 5DF1F5E5
P 1950 1450
F 0 "#PWR0101" H 1950 1200 50  0001 C CNN
F 1 "GND" H 1955 1277 50  0000 C CNN
F 2 "" H 1950 1450 50  0001 C CNN
F 3 "" H 1950 1450 50  0001 C CNN
	1    1950 1450
	1    0    0    -1  
$EndComp
Wire Wire Line
	1850 1250 1950 1250
Wire Wire Line
	5750 2950 5750 3000
Wire Wire Line
	5750 3000 5850 3000
Wire Wire Line
	5850 3000 5850 2950
Connection ~ 5750 3000
Wire Wire Line
	5750 3000 5750 3400
$Comp
L LnConnectors:CONN_02 J?
U 1 1 5DF28262
P 950 1300
F 0 "J?" H 1006 1787 60  0001 C CNN
F 1 "220V" V 800 1500 60  0000 C CNN
F 2 "" H 950 1300 60  0000 C CNN
F 3 "" H 950 1300 60  0000 C CNN
	1    950  1300
	1    0    0    -1  
$EndComp
Text Notes 6750 3600 0    50   ~ 0
Celeste
Text Notes 6750 3700 0    50   ~ 0
Bianco/Celeste
Text Notes 6750 3400 0    50   ~ 0
Marrone
Text Notes 6750 3500 0    50   ~ 0
Bianco/Marrone
Text Notes 6750 3000 0    50   ~ 0
Arancio
Text Notes 6750 3100 0    50   ~ 0
Bianco/Arancio
Text Notes 6750 3200 0    50   ~ 0
Verde
Wire Wire Line
	10700 1050 9950 1050
$Comp
L power:GNDA #PWR0104
U 1 1 5DF0F3FB
P 10450 5500
F 0 "#PWR0104" H 10450 5250 50  0001 C CNN
F 1 "GNDA" H 10455 5327 50  0000 C CNN
F 2 "" H 10450 5500 50  0001 C CNN
F 3 "" H 10450 5500 50  0001 C CNN
	1    10450 5500
	1    0    0    -1  
$EndComp
$Comp
L LnDevice:sOnOff_Basic K?
U 1 1 5DEED482
P 9600 1250
F 0 "K?" H 9600 1692 50  0000 C CNN
F 1 "sOnOff_Basic" H 9600 1601 50  0000 C CNN
F 2 "sOnOff" H 9700 1025 25  0001 L CNN
F 3 "https://standexelectronics.com/wp-content/uploads/datasheet_reed_relay_DIP.pdf" H 9625 1075 50  0001 C CNN
	1    9600 1250
	1    0    0    -1  
$EndComp
$Comp
L LnConnectors:Mammuth_09a MM3
U 1 1 5DF28D2C
P 7500 3400
F 0 "MM3" H 7450 3900 40  0000 L CNN
F 1 "Mammuth_09a" H 7628 3400 40  0001 L CNN
F 2 "" H 7525 3650 60  0000 C CNN
F 3 "" H 7525 3650 60  0000 C CNN
	1    7500 3400
	1    0    0    -1  
$EndComp
$Comp
L Device:Speaker LS?
U 1 1 5DF4E72D
P 10650 5050
F 0 "LS?" H 10819 5046 50  0001 L CNN
F 1 "Horn" H 10819 5000 50  0000 L CNN
F 2 "" H 10650 4850 50  0001 C CNN
F 3 "~" H 10640 5000 50  0001 C CNN
	1    10650 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	4150 3400 4450 3400
Wire Wire Line
	4450 2700 4450 2650
Text Label 3900 1650 0    50   ~ 0
pressControlButton
Text Label 3900 1750 0    50   ~ 0
Horn
$Comp
L Graphic:SYM_Arrow_Normal #SYM?
U 1 1 5E07F74E
P 5000 1500
F 0 "#SYM?" H 5000 1560 50  0001 C CNN
F 1 "SYM_Arrow_Normal" H 5010 1450 50  0001 C CNN
F 2 "" H 5000 1500 50  0001 C CNN
F 3 "~" H 5000 1500 50  0001 C CNN
	1    5000 1500
	1    0    0    -1  
$EndComp
$Comp
L Graphic:SYM_Arrow_Normal #SYM?
U 1 1 5E07F78F
P 5100 1600
F 0 "#SYM?" H 5100 1660 50  0001 C CNN
F 1 "SYM_Arrow_Normal" H 5110 1550 50  0001 C CNN
F 2 "" H 5100 1600 50  0001 C CNN
F 3 "~" H 5100 1600 50  0001 C CNN
	1    5100 1600
	-1   0    0    -1  
$EndComp
$Comp
L Graphic:SYM_Arrow_Normal #SYM?
U 1 1 5E07F7A2
P 5100 1700
F 0 "#SYM?" H 5100 1760 50  0001 C CNN
F 1 "SYM_Arrow_Normal" H 5110 1650 50  0001 C CNN
F 2 "" H 5100 1700 50  0001 C CNN
F 3 "~" H 5100 1700 50  0001 C CNN
	1    5100 1700
	-1   0    0    -1  
$EndComp
$Comp
L Graphic:SYM_Arrow_Normal #SYM?
U 1 1 5E07F801
P 4650 2500
F 0 "#SYM?" H 4650 2560 50  0001 C CNN
F 1 "SYM_Arrow_Normal" H 4660 2450 50  0001 C CNN
F 2 "" H 4650 2500 50  0001 C CNN
F 3 "~" H 4650 2500 50  0001 C CNN
	1    4650 2500
	-1   0    0    -1  
$EndComp
$Comp
L Graphic:SYM_Arrow_Normal #SYM?
U 1 1 5E07F814
P 4650 2600
F 0 "#SYM?" H 4650 2660 50  0001 C CNN
F 1 "SYM_Arrow_Normal" H 4660 2550 50  0001 C CNN
F 2 "" H 4650 2600 50  0001 C CNN
F 3 "~" H 4650 2600 50  0001 C CNN
	1    4650 2600
	-1   0    0    -1  
$EndComp
Entry Wire Line
	6600 3100 6700 3000
Entry Wire Line
	6600 3200 6700 3100
Entry Wire Line
	6600 3400 6700 3300
Entry Wire Line
	6600 3800 6700 3700
Entry Wire Line
	6600 3600 6700 3500
$Comp
L LnDevice:Alimentatore Al_5Vcc?
U 1 1 5DF2F833
P 8050 1550
F 0 "Al_5Vcc?" H 8200 1350 40  0001 R CNN
F 1 "Alimentatore" H 8150 1250 40  0001 R CNN
F 2 "5V pressControl" H 8050 1500 30  0000 C CNN
F 3 "" H 8050 1525 60  0000 C CNN
	1    8050 1550
	1    0    0    -1  
$EndComp
Text Notes 700  4900 0    50   ~ 0
Il filo Arancio porta i 5Volt provenienti dalla cisterna. \nL'ho messo in questo modo per rendere indipendente\nil frutto del press control dala presenza di Arduino.
Text Notes 6750 3300 0    50   ~ 0
Bianco/Verde
Wire Wire Line
	6700 3700 7500 3700
Entry Wire Line
	6500 5800 6600 5900
Entry Wire Line
	6500 5700 6600 5800
Entry Wire Line
	6500 4250 6600 4350
Entry Wire Line
	6500 4050 6600 4150
Entry Wire Line
	6500 5900 6600 6000
Entry Wire Line
	6500 4150 6600 4250
Entry Wire Line
	6500 6000 6600 6100
Entry Wire Line
	6500 4350 6600 4450
Entry Wire Line
	6600 3700 6700 3600
Entry Wire Line
	6600 3500 6700 3400
Entry Wire Line
	6600 3300 6700 3200
Wire Wire Line
	6700 3400 7500 3400
Wire Wire Line
	6700 3600 7500 3600
$Comp
L LnDevice:PulsanteNO SW?
U 1 1 5DFEEB6E
P 1950 6250
F 0 "SW?" V 1800 6300 50  0001 C CNN
F 1 "PCButton" V 1950 6100 40  0000 C CNN
F 2 "" H 1950 6250 60  0000 C CNN
F 3 "" H 1950 6250 60  0000 C CNN
	1    1950 6250
	0    -1   -1   0   
$EndComp
$Comp
L Device:LED_ALT D?
U 1 1 5DFEEBE6
P 1000 5700
F 0 "D?" V 1038 5582 50  0001 R CNN
F 1 "PCState" V 1100 5800 50  0000 R CNN
F 2 "" H 1000 5700 50  0001 C CNN
F 3 "~" H 1000 5700 50  0001 C CNN
	1    1000 5700
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1000 5450 1000 5550
Text Label 8600 2800 0    50   ~ 0
pc_button
Wire Wire Line
	10700 1050 10700 3050
Wire Wire Line
	10500 1150 10500 2850
Wire Wire Line
	10400 2850 10500 2850
Connection ~ 10500 2850
Wire Wire Line
	10500 2850 10500 3300
Wire Wire Line
	10400 3050 10700 3050
Connection ~ 10700 3050
Wire Wire Line
	10700 3050 10700 3300
Wire Wire Line
	1000 5100 1000 5150
Wire Wire Line
	1950 6400 1950 6300
Wire Wire Line
	1100 1050 1250 1050
Wire Wire Line
	1100 1150 1150 1150
Wire Wire Line
	1150 1150 1150 1250
Wire Wire Line
	1150 1250 1250 1250
$Comp
L Device:Buzzer BZ?
U 1 1 5E1B1006
P 1500 5500
F 0 "BZ?" H 1550 5500 50  0001 C CNN
F 1 "Active Buzzer" H 1450 5700 50  0000 C CNN
F 2 "" V 1475 5600 50  0001 C CNN
F 3 "~" V 1475 5600 50  0001 C CNN
	1    1500 5500
	-1   0    0    -1  
$EndComp
$Comp
L LnDevice:Alimentatore Al_5Vcc?
U 1 1 5E20E831
P 1550 1150
F 0 "Al_5Vcc?" H 1700 950 40  0001 R CNN
F 1 "Alimentatore" H 1650 850 40  0001 R CNN
F 2 "5V Arduino" H 1550 1150 30  0000 C CNN
F 3 "" H 1550 1125 60  0000 C CNN
	1    1550 1150
	1    0    0    -1  
$EndComp
Wire Wire Line
	1000 5100 1600 5100
Text Notes 800  7250 0    50   ~ 0
Active Buzzer è messo come emergenza nel caso si dovesse rimuovere Arduino.\nSuona in modo continuo quando la pompa è accesa.\nIl jumper si trova dietro il frutto.
Wire Wire Line
	7500 3500 6700 3500
Wire Wire Line
	1600 5950 1600 5600
Connection ~ 1600 5100
Wire Wire Line
	1600 5100 1950 5100
$Comp
L Connector:Conn_01x05_Male J?
U 1 1 5DF8639E
P 3250 6000
F 0 "J?" H 3222 5977 50  0001 R CNN
F 1 "Conn_01x05_Male" H 3223 5932 50  0001 R CNN
F 2 "" H 3250 6000 50  0001 C CNN
F 3 "~" H 3250 6000 50  0001 C CNN
	1    3250 6000
	1    0    0    1   
$EndComp
$Comp
L Connector:Conn_01x05_Female J?
U 1 1 5DF863AD
P 3250 6000
F 0 "J?" H 3278 5980 50  0001 L CNN
F 1 "Conn_01x05_Female" H 3277 5935 50  0001 L CNN
F 2 "" H 3250 6000 50  0001 C CNN
F 3 "~" H 3250 6000 50  0001 C CNN
	1    3250 6000
	1    0    0    1   
$EndComp
Wire Wire Line
	2450 5100 2450 5800
Wire Wire Line
	2450 5800 3050 5800
Entry Wire Line
	6600 3900 6700 3800
Entry Wire Line
	6500 3950 6600 4050
Text Notes 6750 3800 0    50   ~ 0
Calza
Text Label 4200 6200 0    50   ~ 0
pump_ON
Text Label 4200 5900 0    50   ~ 0
pressControl_ON
$Comp
L LnDevice:Edge SW?
U 1 1 5E2F36EA
P 4800 1550
F 0 "SW?" H 4650 1650 70  0001 C CNN
F 1 "Edge" H 4800 1450 70  0001 C CNN
F 2 "" H 4800 1550 60  0000 C CNN
F 3 "" H 4800 1550 60  0000 C CNN
	1    4800 1550
	1    0    0    -1  
$EndComp
Wire Notes Line
	2900 5050 2900 6950
Wire Notes Line
	2900 6950 800  6950
Wire Notes Line
	800  6950 800  5050
Text Notes 1050 6900 0    50   ~ 0
Frutto del PressControl nel Quadro elettrico \ndel Salone
Wire Wire Line
	4150 2550 5250 2550
Wire Wire Line
	4450 2650 5250 2650
Connection ~ 4450 3400
Wire Wire Line
	9500 1600 9500 2200
Wire Wire Line
	9500 2200 9300 2200
Wire Wire Line
	10500 1150 9950 1150
Wire Wire Line
	9700 2300 9300 2300
Wire Wire Line
	10450 5400 10350 5400
Wire Wire Line
	10450 5150 10450 5300
Wire Wire Line
	10450 5300 10350 5300
$Comp
L power:+5VA #PWR0105
U 1 1 5E0633D3
P 10450 4950
F 0 "#PWR0105" H 10450 4800 50  0001 C CNN
F 1 "+5VA" H 10465 5123 50  0000 C CNN
F 2 "" H 10450 4950 50  0001 C CNN
F 3 "" H 10450 4950 50  0001 C CNN
	1    10450 4950
	1    0    0    -1  
$EndComp
Wire Wire Line
	10500 3600 10500 3750
Wire Wire Line
	10700 3600 10700 3950
Wire Wire Line
	10450 3750 10500 3750
Connection ~ 10500 3750
Wire Wire Line
	10500 3750 10500 4400
Wire Wire Line
	10450 3950 10700 3950
Connection ~ 10700 3950
Wire Wire Line
	10700 3950 10700 4400
$Comp
L power:GNDA #PWR0106
U 1 1 5E0B7431
P 9700 4050
F 0 "#PWR0106" H 9700 3800 50  0001 C CNN
F 1 "GNDA" H 9705 3877 50  0000 C CNN
F 2 "" H 9700 4050 50  0001 C CNN
F 3 "" H 9700 4050 50  0001 C CNN
	1    9700 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	10050 3950 9700 3950
Text Label 3750 4250 0    50   ~ 0
pressControlButton
Wire Wire Line
	3500 1850 5250 1850
Wire Wire Line
	3400 1750 5250 1750
Wire Wire Line
	3300 1650 4650 1650
Wire Wire Line
	3200 1550 5250 1550
Text Label 3900 1850 0    50   ~ 0
ElettroValvola
Wire Wire Line
	7500 3300 6700 3300
Wire Wire Line
	6700 3200 7500 3200
Wire Wire Line
	6700 3100 7500 3100
Wire Wire Line
	6700 3000 7500 3000
Text Notes 5750 4350 0    50   ~ 0
Celeste
Text Notes 5700 5900 0    50   ~ 0
Bianco/Celeste
Text Notes 5700 5700 0    50   ~ 0
Marrone
Text Notes 5700 5800 0    50   ~ 0
Bianco/Marrone
Text Notes 5700 6000 0    50   ~ 0
Arancio
Text Notes 5750 4050 0    50   ~ 0
Bianco/Arancio
Text Notes 5750 4150 0    50   ~ 0
Verde
Text Notes 5750 4250 0    50   ~ 0
Bianco/Verde
Text Notes 5750 3950 0    50   ~ 0
Calza
Text Label 3750 4150 0    50   ~ 0
Horn
Text Label 3750 4050 0    50   ~ 0
ElettroValvola
Text Label 3900 1550 0    50   ~ 0
pump_ON
Text Label 7700 3600 0    50   ~ 0
pump_ON
Text Label 7700 3700 0    50   ~ 0
pressControl_ON
Text Label 7700 3300 0    50   ~ 0
pressControlButton
Text Label 7700 3200 0    50   ~ 0
Horn
Text Label 7700 3100 0    50   ~ 0
ElettroValvola
Wire Wire Line
	9700 3850 10050 3850
Wire Wire Line
	8900 5550 9650 5550
$Comp
L LnDevice:RELAY_1RT K?
U 1 1 5E252A8F
P 10200 3000
F 0 "K?" H 10200 3539 70  0001 C CNN
F 1 "RELAY_2RT" H 10200 3539 70  0001 C CNN
F 2 "" H 10200 3020 60  0000 C CNN
F 3 "" H 10200 3020 60  0000 C CNN
	1    10200 3000
	-1   0    0    -1  
$EndComp
Wire Wire Line
	9700 1600 9700 2300
$Comp
L power:+5VA #PWR0109
U 1 1 5DFBEA28
P 8450 1400
F 0 "#PWR0109" H 8450 1250 50  0001 C CNN
F 1 "+5VA" H 8465 1573 50  0000 C CNN
F 2 "" H 8450 1400 50  0001 C CNN
F 3 "" H 8450 1400 50  0001 C CNN
	1    8450 1400
	1    0    0    -1  
$EndComp
$Comp
L power:GNDA #PWR0110
U 1 1 5DFBEA35
P 8450 1700
F 0 "#PWR0110" H 8450 1450 50  0001 C CNN
F 1 "GNDA" H 8455 1527 50  0000 C CNN
F 2 "" H 8450 1700 50  0001 C CNN
F 3 "" H 8450 1700 50  0001 C CNN
	1    8450 1700
	1    0    0    -1  
$EndComp
Wire Wire Line
	8350 1650 8450 1650
Wire Wire Line
	8450 1650 8450 1700
Wire Wire Line
	8350 1450 8450 1450
Wire Wire Line
	8450 1450 8450 1400
$Comp
L LnDevice:Relay_5V_LL_Dual RL?
U 1 1 5DFDEB51
P 8950 2300
F 0 "RL?" H 8950 2625 50  0001 C CNN
F 1 "Relay_5V_LL_Doppio" H 8950 2626 50  0001 C CNN
F 2 "" H 8950 2300 50  0001 C CNN
F 3 "" H 8950 2300 50  0001 C CNN
	1    8950 2300
	1    0    0    -1  
$EndComp
Wire Wire Line
	10450 4950 10450 5050
Wire Wire Line
	10450 5400 10450 5500
$Comp
L LnDevice:Relay_5V_LL_Dual RL?
U 2 1 5DFF5FF9
P 10000 5400
F 0 "RL?" H 10000 5817 50  0000 C CNN
F 1 "Relay_5V_LL_Doppio" H 10000 5726 50  0000 C CNN
F 2 "" H 10000 5400 50  0001 C CNN
F 3 "" H 10000 5400 50  0001 C CNN
	2    10000 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7500 3800 7700 3800
Wire Wire Line
	7700 3800 7700 3950
Connection ~ 7500 3800
Wire Wire Line
	6700 3800 7500 3800
$Comp
L power:GNDA #PWR0111
U 1 1 5DFFBDDA
P 7700 3950
F 0 "#PWR0111" H 7700 3700 50  0001 C CNN
F 1 "GNDA" H 7705 3777 50  0000 C CNN
F 2 "" H 7700 3950 50  0001 C CNN
F 3 "" H 7700 3950 50  0001 C CNN
	1    7700 3950
	1    0    0    -1  
$EndComp
$Comp
L power:GNDA #PWR0112
U 1 1 5E0110BE
P 9600 2950
F 0 "#PWR0112" H 9600 2700 50  0001 C CNN
F 1 "GNDA" H 9605 2777 50  0000 C CNN
F 2 "" H 9600 2950 50  0001 C CNN
F 3 "" H 9600 2950 50  0001 C CNN
	1    9600 2950
	1    0    0    -1  
$EndComp
Wire Wire Line
	9600 2950 10000 2950
Wire Wire Line
	10000 3050 9900 3050
Wire Wire Line
	1000 5850 1000 6000
Wire Wire Line
	1950 6100 1950 6200
Wire Wire Line
	1950 6400 2600 6400
Wire Wire Line
	8600 2450 8600 3300
Wire Wire Line
	8600 3300 7500 3300
Connection ~ 7500 3300
Wire Wire Line
	7500 3200 8900 3200
Wire Wire Line
	8900 3200 8900 5550
Connection ~ 7500 3200
Wire Wire Line
	9700 3950 9700 4050
Wire Wire Line
	7500 3700 9900 3700
Wire Wire Line
	9900 3050 9900 3700
Connection ~ 7500 3700
Wire Wire Line
	7500 3600 9700 3600
Wire Wire Line
	9700 3600 9700 3850
Connection ~ 7500 3600
Text Label 9700 3950 0    50   ~ 0
GNDA_1
Text Label 9600 2950 0    50   ~ 0
GNDA_2
Text Label 10450 5500 0    50   ~ 0
GNDA_3
Wire Wire Line
	3400 1750 3400 4150
Wire Wire Line
	3500 1850 3500 4050
Text Notes 2650 5800 0    50   ~ 0
Red
Text Notes 2650 5900 0    50   ~ 0
Yellow
Text Notes 2650 6000 0    50   ~ 0
White
Text Notes 2650 6100 0    50   ~ 0
Grey
Text Notes 2650 6200 0    50   ~ 0
Black
$Comp
L LnDevice:RELAY_1RT K?
U 1 1 5DFE2D63
P 10250 3900
F 0 "K?" H 10250 4439 70  0001 C CNN
F 1 "RELAY_2RT" H 10250 4439 70  0001 C CNN
F 2 "" H 10250 3920 60  0000 C CNN
F 3 "" H 10250 3920 60  0000 C CNN
	1    10250 3900
	-1   0    0    -1  
$EndComp
Wire Wire Line
	7250 1050 7550 1050
Wire Wire Line
	9250 1150 7650 1150
Wire Wire Line
	7750 1450 7650 1450
Wire Wire Line
	7650 1450 7650 1150
Connection ~ 7650 1150
Wire Wire Line
	7650 1150 7250 1150
Wire Wire Line
	7750 1650 7550 1650
Wire Wire Line
	7550 1650 7550 1050
Connection ~ 7550 1050
Wire Wire Line
	7550 1050 9250 1050
Wire Wire Line
	1950 6100 3050 6100
$Comp
L Device:R R?
U 1 1 5DFF217C
P 4800 1650
F 0 "R?" V 4593 1650 50  0001 C CNN
F 1 "1K" V 4800 1650 50  0000 C CNN
F 2 "" V 4730 1650 50  0001 C CNN
F 3 "~" H 4800 1650 50  0001 C CNN
	1    4800 1650
	0    1    1    0   
$EndComp
$Comp
L Device:R R?
U 1 1 5DFF2270
P 1000 5300
F 0 "R?" V 793 5300 50  0001 C CNN
F 1 "470" V 1000 5300 50  0000 C CNN
F 2 "" V 930 5300 50  0001 C CNN
F 3 "~" H 1000 5300 50  0001 C CNN
	1    1000 5300
	-1   0    0    1   
$EndComp
$Comp
L Device:LED_ALT D?
U 1 1 5E00178D
P 1950 5700
F 0 "D?" V 1988 5582 50  0001 R CNN
F 1 "PumpState" V 2050 5800 50  0000 R CNN
F 2 "" H 1950 5700 50  0001 C CNN
F 3 "~" H 1950 5700 50  0001 C CNN
	1    1950 5700
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 5E001794
P 1950 5300
F 0 "R?" V 1743 5300 50  0001 C CNN
F 1 "470" V 1950 5300 50  0000 C CNN
F 2 "" V 1880 5300 50  0001 C CNN
F 3 "~" H 1950 5300 50  0001 C CNN
	1    1950 5300
	-1   0    0    1   
$EndComp
Wire Wire Line
	1600 5400 1600 5100
Wire Wire Line
	1950 5850 1950 5900
Wire Wire Line
	1950 5900 2950 5900
Wire Wire Line
	1950 5450 1950 5550
Wire Wire Line
	1950 5100 1950 5150
Connection ~ 1950 5100
Wire Wire Line
	1950 5100 2450 5100
$Comp
L LnConnectors:JUMPER JP?
U 1 1 5E0960EC
P 3250 5500
F 0 "JP?" H 3100 5525 60  0001 C CNN
F 1 "JUMPER" H 3150 5400 40  0001 C CNN
F 2 "" H 3250 5525 60  0000 C CNN
F 3 "" H 3250 5525 60  0000 C CNN
	1    3250 5500
	0    1    1    0   
$EndComp
Wire Wire Line
	1000 6000 3050 6000
Wire Wire Line
	5950 700  5950 950 
$Comp
L power:+5V #PWR0102
U 1 1 5E0C7A38
P 1950 1000
F 0 "#PWR0102" H 1950 850 50  0001 C CNN
F 1 "+5V" H 1965 1173 50  0000 C CNN
F 2 "" H 1950 1000 50  0001 C CNN
F 3 "" H 1950 1000 50  0001 C CNN
	1    1950 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	1850 1050 1950 1050
Text Label 3750 3950 0    50   ~ 0
GND_Arduino
Wire Wire Line
	2600 6400 2600 6200
Wire Wire Line
	2600 6200 3050 6200
$Comp
L power:+5VA #PWR0103
U 1 1 5E0916E7
P 7700 2850
F 0 "#PWR0103" H 7700 2700 50  0001 C CNN
F 1 "+5VA" H 7715 3023 50  0000 C CNN
F 2 "" H 7700 2850 50  0001 C CNN
F 3 "" H 7700 2850 50  0001 C CNN
	1    7700 2850
	1    0    0    -1  
$EndComp
Wire Wire Line
	7500 3000 7700 3000
Wire Wire Line
	7700 3000 7700 2850
Connection ~ 7500 3000
Text Label 4200 6000 0    50   ~ 0
(+5Vcc)
Text Label 3750 4350 0    50   ~ 0
pump_ON
Text Label 4200 6100 0    50   ~ 0
pressControlButton
Wire Wire Line
	4450 3400 5750 3400
Wire Notes Line
	800  5050 2900 5050
Wire Notes Line
	2750 650  2750 3450
Wire Notes Line
	2750 3450 6450 3450
Wire Notes Line
	6450 3450 6450 650 
Wire Notes Line
	6450 650  2750 650 
Text Notes 2950 850  0    50   ~ 0
Frutto contenente Arduino nel Quadro elettrico \ndel Salone
$Comp
L Connector:Conn_01x05_Male J?
U 1 1 5E23680F
P 4800 4150
F 0 "J?" H 4772 4127 50  0001 R CNN
F 1 "Conn_01x05_Male" H 4773 4082 50  0001 R CNN
F 2 "" H 4800 4150 50  0001 C CNN
F 3 "~" H 4800 4150 50  0001 C CNN
	1    4800 4150
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x02_Female J?
U 1 1 5E236824
P 2450 1200
F 0 "J?" H 2478 1180 50  0001 L CNN
F 1 "Conn_01x05_Female" H 2477 1135 50  0001 L CNN
F 2 "" H 2450 1200 50  0001 C CNN
F 3 "~" H 2450 1200 50  0001 C CNN
	1    2450 1200
	1    0    0    1   
$EndComp
Wire Wire Line
	4950 1650 5250 1650
Wire Wire Line
	1950 1050 1950 1100
Connection ~ 1950 1050
Wire Wire Line
	1950 1250 1950 1200
Connection ~ 1950 1250
$Comp
L Connector:Conn_01x02_Male J?
U 1 1 5E268A05
P 2450 1200
F 0 "J?" H 2478 1180 50  0001 L CNN
F 1 "Conn_01x05_Female" H 2477 1135 50  0001 L CNN
F 2 "" H 2450 1200 50  0001 C CNN
F 3 "~" H 2450 1200 50  0001 C CNN
	1    2450 1200
	1    0    0    1   
$EndComp
Wire Wire Line
	5950 700  5050 700 
Wire Wire Line
	5750 3400 6400 3400
Wire Wire Line
	6400 3400 6400 850 
Wire Wire Line
	6400 850  5150 850 
Connection ~ 5750 3400
Wire Wire Line
	1950 1250 1950 1450
Wire Wire Line
	1950 1050 1950 1000
Wire Wire Line
	2650 1200 5150 1200
Wire Wire Line
	5150 850  5150 1200
Wire Wire Line
	5050 700  5050 1100
Wire Wire Line
	2650 1100 5050 1100
Wire Wire Line
	1950 1200 2250 1200
Wire Wire Line
	1950 1100 2250 1100
Wire Wire Line
	3600 3400 3600 3950
Connection ~ 4150 3400
$Comp
L Connector:Conn_01x05_Female J?
U 1 1 5E110269
P 4750 4150
F 0 "J?" H 4722 4127 50  0001 R CNN
F 1 "Conn_01x05_Male" H 4723 4082 50  0001 R CNN
F 2 "" H 4750 4150 50  0001 C CNN
F 3 "~" H 4750 4150 50  0001 C CNN
	1    4750 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	3600 3950 4550 3950
Wire Wire Line
	3500 4050 4550 4050
Wire Wire Line
	5000 4050 6500 4050
Wire Wire Line
	3400 4150 4550 4150
Wire Wire Line
	4550 4250 3300 4250
Wire Wire Line
	3300 1650 3300 4250
Wire Wire Line
	4550 4350 3200 4350
Wire Wire Line
	3200 1550 3200 4350
Wire Wire Line
	5000 4150 6500 4150
$Comp
L Connector:Conn_01x05_Male J?
U 1 1 5E1C4614
P 5150 6000
F 0 "J?" H 5122 5977 50  0001 R CNN
F 1 "Conn_01x05_Male" H 5123 5932 50  0001 R CNN
F 2 "" H 5150 6000 50  0001 C CNN
F 3 "~" H 5150 6000 50  0001 C CNN
	1    5150 6000
	-1   0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x05_Female J?
U 1 1 5E1C4625
P 5200 6000
F 0 "J?" H 5172 5977 50  0001 R CNN
F 1 "Conn_01x05_Male" H 5173 5932 50  0001 R CNN
F 2 "" H 5200 6000 50  0001 C CNN
F 3 "~" H 5200 6000 50  0001 C CNN
	1    5200 6000
	-1   0    0    -1  
$EndComp
Wire Wire Line
	5250 1950 3800 1950
Wire Wire Line
	3800 1950 3800 3750
Wire Wire Line
	5000 3950 5450 3950
Wire Wire Line
	5000 4250 5550 4250
Wire Wire Line
	5000 4350 5650 4350
Wire Wire Line
	5450 3950 5450 5800
Wire Wire Line
	5450 5800 5400 5800
Connection ~ 5450 3950
Wire Wire Line
	5450 3950 6500 3950
Wire Wire Line
	5650 4350 5650 6200
Wire Wire Line
	5650 6200 5400 6200
Connection ~ 5650 4350
Wire Wire Line
	5650 4350 6500 4350
Wire Wire Line
	5550 4250 5550 6100
Wire Wire Line
	5550 6100 5400 6100
Connection ~ 5550 4250
Wire Wire Line
	5550 4250 6500 4250
Wire Wire Line
	3450 5800 3800 5800
Wire Wire Line
	3800 5800 3800 6000
Wire Wire Line
	3800 6000 4950 6000
Wire Wire Line
	3450 5900 3700 5900
Wire Wire Line
	3700 5900 3700 6200
Wire Wire Line
	3700 6200 4950 6200
Wire Wire Line
	3450 6200 3550 6200
Wire Wire Line
	3550 6200 3550 6300
Wire Wire Line
	3550 6300 4000 6300
Wire Wire Line
	4000 6300 4000 5800
Wire Wire Line
	4000 5800 4950 5800
Wire Wire Line
	3450 6100 4950 6100
Wire Wire Line
	3450 6000 3600 6000
Wire Wire Line
	3600 6000 3600 5850
Wire Wire Line
	3600 5850 3900 5850
Wire Wire Line
	3900 5850 3900 5900
Wire Wire Line
	3900 5900 4950 5900
Wire Wire Line
	5400 6000 6500 6000
Wire Wire Line
	5400 5900 6500 5900
Text Label 4200 5800 0    50   ~ 0
GND
Text Notes 3200 1550 0    50   ~ 0
White
Text Notes 3300 1650 0    50   ~ 0
Yellow
Text Notes 3400 1750 0    50   ~ 0
Grey
Text Notes 3500 1850 0    50   ~ 0
Orange
Text Notes 3800 1950 0    50   ~ 0
Red
Wire Wire Line
	5700 5700 6500 5700
Wire Wire Line
	5700 5800 6500 5800
$Comp
L Connector:Conn_01x02_Female J?
U 1 1 5E19B6D0
P 3200 5550
F 0 "J?" H 3172 5527 50  0001 R CNN
F 1 "Conn_01x05_Male" H 3173 5482 50  0001 R CNN
F 2 "" H 3200 5550 50  0001 C CNN
F 3 "~" H 3200 5550 50  0001 C CNN
	1    3200 5550
	1    0    0    1   
$EndComp
Connection ~ 4950 5800
Wire Wire Line
	4950 5800 5050 5800
Wire Wire Line
	1600 5950 2600 5950
Wire Wire Line
	2600 5950 2600 5450
Wire Wire Line
	2600 5450 3000 5450
Wire Wire Line
	2950 5900 2950 5550
Wire Wire Line
	2950 5550 3000 5550
Connection ~ 2950 5900
Wire Wire Line
	2950 5900 3050 5900
Text Notes 3350 5550 0    50   ~ 0
Enable Buzzer
$Comp
L LnConnectors:JUMPER JP?
U 1 1 5E1F9FD1
P 4800 3700
F 0 "JP?" H 4650 3725 60  0001 C CNN
F 1 "JUMPER" H 4700 3600 40  0001 C CNN
F 2 "" H 4800 3725 60  0000 C CNN
F 3 "" H 4800 3725 60  0000 C CNN
	1    4800 3700
	0    1    1    0   
$EndComp
$Comp
L Connector:Conn_01x02_Female J?
U 1 1 5E1F9FD7
P 4750 3750
F 0 "J?" H 4722 3727 50  0001 R CNN
F 1 "Conn_01x05_Male" H 4723 3682 50  0001 R CNN
F 2 "" H 4750 3750 50  0001 C CNN
F 3 "~" H 4750 3750 50  0001 C CNN
	1    4750 3750
	1    0    0    1   
$EndComp
Text Notes 4900 3750 0    50   ~ 0
TEST\nAlarm
Wire Wire Line
	3600 3400 4150 3400
Wire Wire Line
	4150 3400 4150 3650
Wire Wire Line
	4150 3650 4550 3650
Wire Wire Line
	3800 3750 4550 3750
Wire Bus Line
	6600 2950 6600 6200
$EndSCHEMATC
