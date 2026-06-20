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
P 6400 1950
F 0 "A?" H 6400 864 50  0001 C CNN
F 1 "Arduino_Nano_v3.x" V 6400 1800 50  0000 C CNN
F 2 "Module:Arduino_Nano" H 6550 1000 50  0001 L CNN
F 3 "http://www.mouser.com/pdfdocs/Gravitech_Arduino_Nano3_0.pdf" H 6400 950 50  0001 C CNN
	1    6400 1950
	1    0    0    -1  
$EndComp
$Comp
L Device:R_US R?
U 1 1 5DEB74D1
P 5100 2850
F 0 "R?" H 5168 2896 50  0001 L CNN
F 1 "470" H 5168 2805 50  0000 L CNN
F 2 "" V 5140 2840 50  0001 C CNN
F 3 "~" H 5100 2850 50  0001 C CNN
	1    5100 2850
	1    0    0    -1  
$EndComp
$Comp
L Device:LED_ALT D?
U 1 1 5DEB73CD
P 5100 3200
F 0 "D?" V 5138 3082 50  0001 R CNN
F 1 "BlinkingLED" V 5047 3082 50  0000 R CNN
F 2 "" H 5100 3200 50  0001 C CNN
F 3 "~" H 5100 3200 50  0001 C CNN
	1    5100 3200
	0    -1   -1   0   
$EndComp
$Comp
L Device:Buzzer BZ?
U 1 1 5DEBAA3F
P 4700 2850
F 0 "BZ?" H 4750 2850 50  0001 C CNN
F 1 "Passive Buzzer" H 4700 2600 50  0000 C CNN
F 2 "" V 4675 2950 50  0001 C CNN
F 3 "~" V 4675 2950 50  0001 C CNN
	1    4700 2850
	-1   0    0    -1  
$EndComp
$Comp
L LnConnectors:CONN_02 J?
U 1 1 5DEBCAE0
P 8200 1300
F 0 "J?" V 8203 1628 60  0001 L CNN
F 1 "220V" V 8100 1400 60  0000 L CNN
F 2 "" H 8200 1300 60  0000 C CNN
F 3 "" H 8200 1300 60  0000 C CNN
	1    8200 1300
	1    0    0    -1  
$EndComp
Wire Wire Line
	5100 3000 5100 3050
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
	4800 2950 4800 3400
Wire Wire Line
	5100 3350 5100 3400
Text Label 5450 2550 0    50   ~ 0
Buzzer
Text Label 5450 2650 0    50   ~ 0
BlinkingLED
Wire Wire Line
	4800 2750 4800 2550
$Comp
L power:GND #PWR0101
U 1 1 5DF1F5E5
P 2600 1450
F 0 "#PWR0101" H 2600 1200 50  0001 C CNN
F 1 "GND" H 2605 1277 50  0000 C CNN
F 2 "" H 2600 1450 50  0001 C CNN
F 3 "" H 2600 1450 50  0001 C CNN
	1    2600 1450
	1    0    0    -1  
$EndComp
Wire Wire Line
	2500 1250 2600 1250
Wire Wire Line
	6400 2950 6400 3000
Wire Wire Line
	6400 3000 6500 3000
Wire Wire Line
	6500 3000 6500 2950
Connection ~ 6400 3000
Wire Wire Line
	6400 3000 6400 3400
$Comp
L LnConnectors:CONN_02 J?
U 1 1 5DF28262
P 1600 1300
F 0 "J?" H 1656 1787 60  0001 C CNN
F 1 "220V" V 1450 1500 60  0000 C CNN
F 2 "" H 1600 1300 60  0000 C CNN
F 3 "" H 1600 1300 60  0000 C CNN
	1    1600 1300
	1    0    0    -1  
$EndComp
Text Notes 7550 3600 0    50   ~ 0
Celeste
Text Notes 7550 3700 0    50   ~ 0
Bianco/Celeste
Text Notes 7550 3400 0    50   ~ 0
Marrone
Text Notes 7550 3500 0    50   ~ 0
Bianco/Marrone
Text Notes 7550 3000 0    50   ~ 0
Arancio
Text Notes 7550 3100 0    50   ~ 0
Bianco/Arancio
Text Notes 7550 3200 0    50   ~ 0
Verde
Wire Wire Line
	10700 1050 10450 1050
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
P 10100 1250
F 0 "K?" H 10100 1692 50  0000 C CNN
F 1 "sOnOff_Basic" H 10100 1601 50  0000 C CNN
F 2 "sOnOff" H 10200 1025 25  0001 L CNN
F 3 "https://standexelectronics.com/wp-content/uploads/datasheet_reed_relay_DIP.pdf" H 10125 1075 50  0001 C CNN
	1    10100 1250
	1    0    0    -1  
$EndComp
$Comp
L LnConnectors:Mammuth_09a MM3
U 1 1 5DF28D2C
P 8300 3400
F 0 "MM3" H 8250 3900 40  0000 L CNN
F 1 "Mammuth_09a" H 8428 3400 40  0001 L CNN
F 2 "" H 8325 3650 60  0000 C CNN
F 3 "" H 8325 3650 60  0000 C CNN
	1    8300 3400
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
	4800 3400 5100 3400
Wire Wire Line
	5100 2700 5100 2650
Text Label 4550 1650 0    50   ~ 0
pressControlButton
Text Label 4550 1750 0    50   ~ 0
Horn
$Comp
L Graphic:SYM_Arrow_Normal #SYM?
U 1 1 5E07F74E
P 5650 1500
F 0 "#SYM?" H 5650 1560 50  0001 C CNN
F 1 "SYM_Arrow_Normal" H 5660 1450 50  0001 C CNN
F 2 "" H 5650 1500 50  0001 C CNN
F 3 "~" H 5650 1500 50  0001 C CNN
	1    5650 1500
	1    0    0    -1  
$EndComp
$Comp
L Graphic:SYM_Arrow_Normal #SYM?
U 1 1 5E07F78F
P 5750 1600
F 0 "#SYM?" H 5750 1660 50  0001 C CNN
F 1 "SYM_Arrow_Normal" H 5760 1550 50  0001 C CNN
F 2 "" H 5750 1600 50  0001 C CNN
F 3 "~" H 5750 1600 50  0001 C CNN
	1    5750 1600
	-1   0    0    -1  
$EndComp
$Comp
L Graphic:SYM_Arrow_Normal #SYM?
U 1 1 5E07F7A2
P 5750 1700
F 0 "#SYM?" H 5750 1760 50  0001 C CNN
F 1 "SYM_Arrow_Normal" H 5760 1650 50  0001 C CNN
F 2 "" H 5750 1700 50  0001 C CNN
F 3 "~" H 5750 1700 50  0001 C CNN
	1    5750 1700
	-1   0    0    -1  
$EndComp
$Comp
L Graphic:SYM_Arrow_Normal #SYM?
U 1 1 5E07F801
P 5300 2500
F 0 "#SYM?" H 5300 2560 50  0001 C CNN
F 1 "SYM_Arrow_Normal" H 5310 2450 50  0001 C CNN
F 2 "" H 5300 2500 50  0001 C CNN
F 3 "~" H 5300 2500 50  0001 C CNN
	1    5300 2500
	-1   0    0    -1  
$EndComp
$Comp
L Graphic:SYM_Arrow_Normal #SYM?
U 1 1 5E07F814
P 5300 2600
F 0 "#SYM?" H 5300 2660 50  0001 C CNN
F 1 "SYM_Arrow_Normal" H 5310 2550 50  0001 C CNN
F 2 "" H 5300 2600 50  0001 C CNN
F 3 "~" H 5300 2600 50  0001 C CNN
	1    5300 2600
	-1   0    0    -1  
$EndComp
Entry Wire Line
	7400 3100 7500 3000
Entry Wire Line
	7400 3200 7500 3100
Entry Wire Line
	7400 3400 7500 3300
Entry Wire Line
	7400 3800 7500 3700
Entry Wire Line
	7400 3600 7500 3500
$Comp
L LnDevice:Alimentatore Al_5Vcc?
U 1 1 5DF2F833
P 9150 1550
F 0 "Al_5Vcc?" H 9300 1350 40  0001 R CNN
F 1 "Alimentatore" H 9250 1250 40  0001 R CNN
F 2 "5V pressControl" H 9150 1500 30  0000 C CNN
F 3 "" H 9150 1525 60  0000 C CNN
	1    9150 1550
	1    0    0    -1  
$EndComp
Text Notes 1350 4900 0    50   ~ 0
Il filo Arancio porta i 5Volt verso il relè presente in cisterna. \nProvvede ad alimentare solo la parte logica e non la bobina che sarà\nalimentata localmente come anche la sirena.\n
Text Notes 7550 3300 0    50   ~ 0
Bianco/Verde
Wire Wire Line
	7500 3700 8300 3700
Entry Wire Line
	7300 5800 7400 5900
Entry Wire Line
	7300 5700 7400 5800
Entry Wire Line
	7300 4250 7400 4350
Entry Wire Line
	7300 4050 7400 4150
Entry Wire Line
	7300 5900 7400 6000
Entry Wire Line
	7300 4150 7400 4250
Entry Wire Line
	7300 6000 7400 6100
Entry Wire Line
	7300 4350 7400 4450
Entry Wire Line
	7400 3700 7500 3600
Entry Wire Line
	7400 3500 7500 3400
Entry Wire Line
	7400 3300 7500 3200
Wire Wire Line
	7500 3400 8300 3400
Wire Wire Line
	7500 3600 8300 3600
$Comp
L LnDevice:PulsanteNO SW?
U 1 1 5DFEEB6E
P 2600 6250
F 0 "SW?" V 2450 6300 50  0001 C CNN
F 1 "PCButton" V 2600 6100 40  0000 C CNN
F 2 "" H 2600 6250 60  0000 C CNN
F 3 "" H 2600 6250 60  0000 C CNN
	1    2600 6250
	0    -1   -1   0   
$EndComp
$Comp
L Device:LED_ALT D?
U 1 1 5DFEEBE6
P 1650 5700
F 0 "D?" V 1688 5582 50  0001 R CNN
F 1 "PCState" V 1750 5800 50  0000 R CNN
F 2 "" H 1650 5700 50  0001 C CNN
F 3 "~" H 1650 5700 50  0001 C CNN
	1    1650 5700
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1650 5450 1650 5550
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
	1650 5100 1650 5150
Wire Wire Line
	2600 6400 2600 6300
Wire Wire Line
	1750 1050 1900 1050
Wire Wire Line
	1750 1150 1800 1150
Wire Wire Line
	1800 1150 1800 1250
Wire Wire Line
	1800 1250 1900 1250
$Comp
L Device:Buzzer BZ?
U 1 1 5E1B1006
P 2150 5500
F 0 "BZ?" H 2200 5500 50  0001 C CNN
F 1 "Active Buzzer" H 2100 5700 50  0000 C CNN
F 2 "" V 2125 5600 50  0001 C CNN
F 3 "~" V 2125 5600 50  0001 C CNN
	1    2150 5500
	-1   0    0    -1  
$EndComp
$Comp
L LnDevice:Alimentatore Al_5Vcc?
U 1 1 5E20E831
P 2200 1150
F 0 "Al_5Vcc?" H 2350 950 40  0001 R CNN
F 1 "Alimentatore" H 2300 850 40  0001 R CNN
F 2 "5V Arduino" H 2200 1150 30  0000 C CNN
F 3 "" H 2200 1125 60  0000 C CNN
	1    2200 1150
	1    0    0    -1  
$EndComp
Wire Wire Line
	1650 5100 2250 5100
Text Notes 1450 7250 0    50   ~ 0
Active Buzzer è messo come emergenza nel caso si dovesse rimuovere Arduino.\nSuona in modo continuo quando la pompa è accesa.\nIl jumper si trova dietro il frutto.
Wire Wire Line
	8300 3500 7500 3500
Wire Wire Line
	2250 5950 2250 5600
Connection ~ 2250 5100
Wire Wire Line
	2250 5100 2600 5100
$Comp
L Connector:Conn_01x05_Male J?
U 1 1 5DF8639E
P 3900 6000
F 0 "J?" H 3872 5977 50  0001 R CNN
F 1 "Conn_01x05_Male" H 3873 5932 50  0001 R CNN
F 2 "" H 3900 6000 50  0001 C CNN
F 3 "~" H 3900 6000 50  0001 C CNN
	1    3900 6000
	1    0    0    1   
$EndComp
$Comp
L Connector:Conn_01x05_Female J?
U 1 1 5DF863AD
P 3900 6000
F 0 "J?" H 3928 5980 50  0001 L CNN
F 1 "Conn_01x05_Female" H 3927 5935 50  0001 L CNN
F 2 "" H 3900 6000 50  0001 C CNN
F 3 "~" H 3900 6000 50  0001 C CNN
	1    3900 6000
	1    0    0    1   
$EndComp
Wire Wire Line
	3100 5100 3100 5800
Wire Wire Line
	3100 5800 3700 5800
Entry Wire Line
	7400 3900 7500 3800
Entry Wire Line
	7300 3950 7400 4050
Text Notes 7550 3800 0    50   ~ 0
Calza
Text Label 4850 6200 0    50   ~ 0
pump_ON
Text Label 4850 5900 0    50   ~ 0
pressControl_ON
$Comp
L LnDevice:Edge SW?
U 1 1 5E2F36EA
P 5450 1550
F 0 "SW?" H 5300 1650 70  0001 C CNN
F 1 "Edge" H 5450 1450 70  0001 C CNN
F 2 "" H 5450 1550 60  0000 C CNN
F 3 "" H 5450 1550 60  0000 C CNN
	1    5450 1550
	1    0    0    -1  
$EndComp
Wire Notes Line
	3550 5050 3550 6950
Wire Notes Line
	3550 6950 1450 6950
Wire Notes Line
	1450 6950 1450 5050
Text Notes 1700 6900 0    50   ~ 0
Frutto del PressControl nel Quadro elettrico \ndel Salone
Wire Wire Line
	4800 2550 5900 2550
Wire Wire Line
	5100 2650 5900 2650
Connection ~ 5100 3400
Wire Wire Line
	10000 1600 10000 2200
Wire Wire Line
	10000 2200 9450 2200
Wire Wire Line
	10500 1150 10450 1150
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
Text Label 4400 4250 0    50   ~ 0
pressControlButton
Wire Wire Line
	4150 1850 5900 1850
Wire Wire Line
	4050 1750 5900 1750
Wire Wire Line
	3950 1650 5300 1650
Wire Wire Line
	3850 1550 5900 1550
Text Label 4550 1850 0    50   ~ 0
ElettroValvola
Wire Wire Line
	8300 3300 7500 3300
Wire Wire Line
	7500 3200 8300 3200
Wire Wire Line
	7500 3100 8300 3100
Wire Wire Line
	7500 3000 8300 3000
Text Notes 6400 4350 0    50   ~ 0
Celeste
Text Notes 6350 5900 0    50   ~ 0
Bianco/Celeste
Text Notes 6350 5700 0    50   ~ 0
Marrone
Text Notes 6350 5800 0    50   ~ 0
Bianco/Marrone
Text Notes 6350 6000 0    50   ~ 0
Arancio
Text Notes 6400 4050 0    50   ~ 0
Bianco/Arancio
Text Notes 6400 4150 0    50   ~ 0
Verde
Text Notes 6400 4250 0    50   ~ 0
Bianco/Verde
Text Notes 6400 3950 0    50   ~ 0
Calza
Text Label 4400 4150 0    50   ~ 0
Horn
Text Label 4400 4050 0    50   ~ 0
ElettroValvola
Text Label 4550 1550 0    50   ~ 0
pump_ON
Text Label 8500 3600 0    50   ~ 0
pump_ON
Text Label 8500 3700 0    50   ~ 0
pressControl_ON
Text Label 8500 3300 0    50   ~ 0
pressControlButton
Text Label 8500 3200 0    50   ~ 0
Horn
Text Label 8500 3100 0    50   ~ 0
ElettroValvola
Wire Wire Line
	9700 3850 10050 3850
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
	10200 1600 10200 1700
$Comp
L power:+5VA #PWR0109
U 1 1 5DFBEA28
P 9550 1400
F 0 "#PWR0109" H 9550 1250 50  0001 C CNN
F 1 "+5VA" H 9565 1573 50  0000 C CNN
F 2 "" H 9550 1400 50  0001 C CNN
F 3 "" H 9550 1400 50  0001 C CNN
	1    9550 1400
	1    0    0    -1  
$EndComp
$Comp
L power:GNDA #PWR0110
U 1 1 5DFBEA35
P 9550 1700
F 0 "#PWR0110" H 9550 1450 50  0001 C CNN
F 1 "GNDA" H 9555 1527 50  0000 C CNN
F 2 "" H 9550 1700 50  0001 C CNN
F 3 "" H 9550 1700 50  0001 C CNN
	1    9550 1700
	1    0    0    -1  
$EndComp
Wire Wire Line
	9450 1650 9550 1650
Wire Wire Line
	9550 1650 9550 1700
Wire Wire Line
	9450 1450 9550 1450
Wire Wire Line
	9550 1450 9550 1400
Wire Wire Line
	10450 4950 10450 5050
Wire Wire Line
	10450 5400 10450 5500
$Comp
L LnDevice:Relay_5V_LL_Dual_New RL?
U 2 1 5DFF5FF9
P 10000 5400
F 0 "RL?" H 10150 5300 50  0000 C CNN
F 1 "Relay_5V_LL_Doppio" H 10500 5000 50  0000 C CNN
F 2 "" H 10000 5400 50  0001 C CNN
F 3 "" H 10000 5400 50  0001 C CNN
	2    10000 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	8300 3800 8500 3800
Wire Wire Line
	8500 3800 8500 3950
Connection ~ 8300 3800
Wire Wire Line
	7500 3800 8300 3800
$Comp
L power:GNDA #PWR0111
U 1 1 5DFFBDDA
P 8500 3950
F 0 "#PWR0111" H 8500 3700 50  0001 C CNN
F 1 "GNDA" H 8505 3777 50  0000 C CNN
F 2 "" H 8500 3950 50  0001 C CNN
F 3 "" H 8500 3950 50  0001 C CNN
	1    8500 3950
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
	1650 5850 1650 6000
Wire Wire Line
	2600 6100 2600 6200
Wire Wire Line
	2600 6400 3250 6400
Wire Wire Line
	9450 2200 9450 3300
Wire Wire Line
	9450 3300 8300 3300
Connection ~ 8300 3300
Wire Wire Line
	8300 3200 9300 3200
Wire Wire Line
	9300 3200 9300 5550
Connection ~ 8300 3200
Wire Wire Line
	9700 3950 9700 4050
Wire Wire Line
	8300 3700 9900 3700
Wire Wire Line
	9900 3050 9900 3700
Connection ~ 8300 3700
Wire Wire Line
	8300 3600 9700 3600
Wire Wire Line
	9700 3600 9700 3850
Connection ~ 8300 3600
Text Label 9700 3950 0    50   ~ 0
GNDA_1
Text Label 9600 2950 0    50   ~ 0
GNDA_2
Text Label 10450 5500 0    50   ~ 0
GNDA_3
Wire Wire Line
	4050 1750 4050 4150
Wire Wire Line
	4150 1850 4150 4050
Text Notes 3300 5800 0    50   ~ 0
Red
Text Notes 3300 5900 0    50   ~ 0
Yellow
Text Notes 3300 6000 0    50   ~ 0
White
Text Notes 3300 6100 0    50   ~ 0
Grey
Text Notes 3300 6200 0    50   ~ 0
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
	8350 1050 8650 1050
Wire Wire Line
	9750 1150 8750 1150
Wire Wire Line
	8850 1450 8750 1450
Wire Wire Line
	8750 1450 8750 1150
Connection ~ 8750 1150
Wire Wire Line
	8750 1150 8350 1150
Wire Wire Line
	8850 1650 8650 1650
Wire Wire Line
	8650 1650 8650 1050
Connection ~ 8650 1050
Wire Wire Line
	8650 1050 9750 1050
Wire Wire Line
	2600 6100 3700 6100
$Comp
L Device:R R?
U 1 1 5DFF217C
P 5450 1650
F 0 "R?" V 5243 1650 50  0001 C CNN
F 1 "1K" V 5450 1650 50  0000 C CNN
F 2 "" V 5380 1650 50  0001 C CNN
F 3 "~" H 5450 1650 50  0001 C CNN
	1    5450 1650
	0    1    1    0   
$EndComp
$Comp
L Device:R R?
U 1 1 5DFF2270
P 1650 5300
F 0 "R?" V 1443 5300 50  0001 C CNN
F 1 "470" V 1650 5300 50  0000 C CNN
F 2 "" V 1580 5300 50  0001 C CNN
F 3 "~" H 1650 5300 50  0001 C CNN
	1    1650 5300
	-1   0    0    1   
$EndComp
$Comp
L Device:LED_ALT D?
U 1 1 5E00178D
P 2600 5700
F 0 "D?" V 2638 5582 50  0001 R CNN
F 1 "PumpState" V 2700 5800 50  0000 R CNN
F 2 "" H 2600 5700 50  0001 C CNN
F 3 "~" H 2600 5700 50  0001 C CNN
	1    2600 5700
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 5E001794
P 2600 5300
F 0 "R?" V 2393 5300 50  0001 C CNN
F 1 "470" V 2600 5300 50  0000 C CNN
F 2 "" V 2530 5300 50  0001 C CNN
F 3 "~" H 2600 5300 50  0001 C CNN
	1    2600 5300
	-1   0    0    1   
$EndComp
Wire Wire Line
	2250 5400 2250 5100
Wire Wire Line
	2600 5850 2600 5900
Wire Wire Line
	2600 5900 3600 5900
Wire Wire Line
	2600 5450 2600 5550
Wire Wire Line
	2600 5100 2600 5150
Connection ~ 2600 5100
Wire Wire Line
	2600 5100 3100 5100
$Comp
L LnConnectors:JUMPER JP?
U 1 1 5E0960EC
P 3900 5500
F 0 "JP?" H 3750 5525 60  0001 C CNN
F 1 "JUMPER" H 3800 5400 40  0001 C CNN
F 2 "" H 3900 5525 60  0000 C CNN
F 3 "" H 3900 5525 60  0000 C CNN
	1    3900 5500
	0    1    1    0   
$EndComp
Wire Wire Line
	1650 6000 3700 6000
Wire Wire Line
	6600 700  6600 950 
$Comp
L power:+5V #PWR0102
U 1 1 5E0C7A38
P 2600 1000
F 0 "#PWR0102" H 2600 850 50  0001 C CNN
F 1 "+5V" H 2615 1173 50  0000 C CNN
F 2 "" H 2600 1000 50  0001 C CNN
F 3 "" H 2600 1000 50  0001 C CNN
	1    2600 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	2500 1050 2600 1050
Text Label 4400 3950 0    50   ~ 0
GND_Arduino
Wire Wire Line
	3250 6400 3250 6200
Wire Wire Line
	3250 6200 3700 6200
Wire Wire Line
	8300 3000 9400 3000
Connection ~ 8300 3000
Text Label 4850 6000 0    50   ~ 0
(+5Vcc)
Text Label 4400 4350 0    50   ~ 0
pump_ON
Text Label 4850 6100 0    50   ~ 0
pressControlButton
Wire Wire Line
	5100 3400 6400 3400
Wire Notes Line
	1450 5050 3550 5050
Wire Notes Line
	3550 650  3550 3450
Wire Notes Line
	3550 3450 7100 3450
Wire Notes Line
	7100 3450 7100 650 
Wire Notes Line
	7200 650  3550 650 
Text Notes 3600 850  0    50   ~ 0
Frutto contenente Arduino nel Quadro elettrico \ndel Salone
$Comp
L Connector:Conn_01x05_Male J?
U 1 1 5E23680F
P 5450 4150
F 0 "J?" H 5422 4127 50  0001 R CNN
F 1 "Conn_01x05_Male" H 5423 4082 50  0001 R CNN
F 2 "" H 5450 4150 50  0001 C CNN
F 3 "~" H 5450 4150 50  0001 C CNN
	1    5450 4150
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x02_Female J?
U 1 1 5E236824
P 3100 1200
F 0 "J?" H 3128 1180 50  0001 L CNN
F 1 "Conn_01x05_Female" H 3127 1135 50  0001 L CNN
F 2 "" H 3100 1200 50  0001 C CNN
F 3 "~" H 3100 1200 50  0001 C CNN
	1    3100 1200
	1    0    0    1   
$EndComp
Wire Wire Line
	5600 1650 5900 1650
Wire Wire Line
	2600 1050 2600 1100
Connection ~ 2600 1050
Wire Wire Line
	2600 1250 2600 1200
Connection ~ 2600 1250
$Comp
L Connector:Conn_01x02_Male J?
U 1 1 5E268A05
P 3100 1200
F 0 "J?" H 3128 1180 50  0001 L CNN
F 1 "Conn_01x05_Female" H 3127 1135 50  0001 L CNN
F 2 "" H 3100 1200 50  0001 C CNN
F 3 "~" H 3100 1200 50  0001 C CNN
	1    3100 1200
	1    0    0    1   
$EndComp
Wire Wire Line
	6600 700  5700 700 
Wire Wire Line
	6400 3400 7050 3400
Wire Wire Line
	7050 3400 7050 850 
Wire Wire Line
	7050 850  5800 850 
Connection ~ 6400 3400
Wire Wire Line
	2600 1250 2600 1450
Wire Wire Line
	2600 1050 2600 1000
Wire Wire Line
	3300 1200 5800 1200
Wire Wire Line
	5800 850  5800 1200
Wire Wire Line
	5700 700  5700 1100
Wire Wire Line
	3300 1100 5700 1100
Wire Wire Line
	2600 1200 2900 1200
Wire Wire Line
	2600 1100 2900 1100
Wire Wire Line
	4250 3400 4250 3950
Connection ~ 4800 3400
$Comp
L Connector:Conn_01x05_Female J?
U 1 1 5E110269
P 5400 4150
F 0 "J?" H 5372 4127 50  0001 R CNN
F 1 "Conn_01x05_Male" H 5373 4082 50  0001 R CNN
F 2 "" H 5400 4150 50  0001 C CNN
F 3 "~" H 5400 4150 50  0001 C CNN
	1    5400 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 3950 5200 3950
Wire Wire Line
	4150 4050 5200 4050
Wire Wire Line
	5650 4050 7300 4050
Wire Wire Line
	4050 4150 5200 4150
Wire Wire Line
	5200 4250 3950 4250
Wire Wire Line
	3950 1650 3950 4250
Wire Wire Line
	5200 4350 3850 4350
Wire Wire Line
	3850 1550 3850 4350
Wire Wire Line
	5650 4150 7300 4150
$Comp
L Connector:Conn_01x05_Male J?
U 1 1 5E1C4614
P 5800 6000
F 0 "J?" H 5772 5977 50  0001 R CNN
F 1 "Conn_01x05_Male" H 5773 5932 50  0001 R CNN
F 2 "" H 5800 6000 50  0001 C CNN
F 3 "~" H 5800 6000 50  0001 C CNN
	1    5800 6000
	-1   0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x05_Female J?
U 1 1 5E1C4625
P 5850 6000
F 0 "J?" H 5822 5977 50  0001 R CNN
F 1 "Conn_01x05_Male" H 5823 5932 50  0001 R CNN
F 2 "" H 5850 6000 50  0001 C CNN
F 3 "~" H 5850 6000 50  0001 C CNN
	1    5850 6000
	-1   0    0    -1  
$EndComp
Wire Wire Line
	5900 1950 4450 1950
Wire Wire Line
	4450 1950 4450 3750
Wire Wire Line
	5650 3950 6100 3950
Wire Wire Line
	5650 4250 6200 4250
Wire Wire Line
	5650 4350 6300 4350
Wire Wire Line
	6100 3950 6100 5800
Wire Wire Line
	6100 5800 6050 5800
Connection ~ 6100 3950
Wire Wire Line
	6100 3950 7300 3950
Wire Wire Line
	6300 4350 6300 6200
Wire Wire Line
	6300 6200 6050 6200
Connection ~ 6300 4350
Wire Wire Line
	6300 4350 7300 4350
Wire Wire Line
	6200 4250 6200 6100
Wire Wire Line
	6200 6100 6050 6100
Connection ~ 6200 4250
Wire Wire Line
	6200 4250 7300 4250
Wire Wire Line
	4100 5800 4450 5800
Wire Wire Line
	4450 5800 4450 6000
Wire Wire Line
	4450 6000 5600 6000
Wire Wire Line
	4100 5900 4350 5900
Wire Wire Line
	4350 5900 4350 6200
Wire Wire Line
	4350 6200 5600 6200
Wire Wire Line
	4100 6200 4200 6200
Wire Wire Line
	4200 6200 4200 6300
Wire Wire Line
	4200 6300 4650 6300
Wire Wire Line
	4100 6100 5600 6100
Wire Wire Line
	4100 6000 4250 6000
Wire Wire Line
	4250 6000 4250 5850
Wire Wire Line
	4250 5850 4550 5850
Wire Wire Line
	4550 5850 4550 5900
Wire Wire Line
	4550 5900 5600 5900
Wire Wire Line
	6050 6000 7300 6000
Wire Wire Line
	6050 5900 7300 5900
Text Label 4850 5800 0    50   ~ 0
GND
Text Notes 3850 1550 0    50   ~ 0
White
Text Notes 3950 1650 0    50   ~ 0
Yellow
Text Notes 4050 1750 0    50   ~ 0
Grey
Text Notes 4150 1850 0    50   ~ 0
Orange
Text Notes 5000 3750 0    50   ~ 0
Red
Wire Wire Line
	6350 5700 7300 5700
Wire Wire Line
	6350 5800 7300 5800
$Comp
L Connector:Conn_01x02_Female J?
U 1 1 5E19B6D0
P 3850 5550
F 0 "J?" H 3822 5527 50  0001 R CNN
F 1 "Conn_01x05_Male" H 3823 5482 50  0001 R CNN
F 2 "" H 3850 5550 50  0001 C CNN
F 3 "~" H 3850 5550 50  0001 C CNN
	1    3850 5550
	1    0    0    1   
$EndComp
Wire Wire Line
	2250 5950 3250 5950
Wire Wire Line
	3250 5950 3250 5450
Wire Wire Line
	3250 5450 3650 5450
Wire Wire Line
	3600 5900 3600 5550
Wire Wire Line
	3600 5550 3650 5550
Connection ~ 3600 5900
Wire Wire Line
	3600 5900 3700 5900
Text Notes 4000 5550 0    50   ~ 0
Enable Buzzer
$Comp
L LnConnectors:JUMPER JP?
U 1 1 5E1F9FD1
P 5450 3700
F 0 "JP?" H 5300 3725 60  0001 C CNN
F 1 "JUMPER" H 5350 3600 40  0001 C CNN
F 2 "" H 5450 3725 60  0000 C CNN
F 3 "" H 5450 3725 60  0000 C CNN
	1    5450 3700
	0    1    1    0   
$EndComp
$Comp
L Connector:Conn_01x02_Female J?
U 1 1 5E1F9FD7
P 5400 3750
F 0 "J?" H 5372 3727 50  0001 R CNN
F 1 "Conn_01x05_Male" H 5373 3682 50  0001 R CNN
F 2 "" H 5400 3750 50  0001 C CNN
F 3 "~" H 5400 3750 50  0001 C CNN
	1    5400 3750
	1    0    0    1   
$EndComp
Text Notes 5550 3750 0    50   ~ 0
TEST\nAlarm
Wire Wire Line
	4250 3400 4800 3400
Wire Wire Line
	4800 3400 4800 3650
Wire Wire Line
	4800 3650 5200 3650
Wire Wire Line
	4450 3750 5200 3750
$Comp
L power:GNDA #PWR?
U 1 1 5E4BEDD8
P 10200 1700
F 0 "#PWR?" H 10200 1450 50  0001 C CNN
F 1 "GNDA" H 10205 1527 50  0000 C CNN
F 2 "" H 10200 1700 50  0001 C CNN
F 3 "" H 10200 1700 50  0001 C CNN
	1    10200 1700
	1    0    0    -1  
$EndComp
Wire Wire Line
	9300 5550 9650 5550
$Comp
L power:GNDA #PWR?
U 1 1 5E4F956D
P 10000 5700
F 0 "#PWR?" H 10000 5450 50  0001 C CNN
F 1 "GNDA" H 10005 5527 50  0000 C CNN
F 2 "" H 10000 5700 50  0001 C CNN
F 3 "" H 10000 5700 50  0001 C CNN
	1    10000 5700
	1    0    0    -1  
$EndComp
Wire Wire Line
	10000 5100 10000 4950
Wire Wire Line
	10000 4950 10450 4950
Connection ~ 10450 4950
Wire Wire Line
	9400 3000 9400 4950
Wire Wire Line
	9400 4950 9800 4950
Wire Wire Line
	9800 4950 9800 5100
Wire Wire Line
	3100 5100 4950 5100
Connection ~ 3100 5100
Wire Wire Line
	4650 5200 4950 5200
$Comp
L power:+5V #PWR?
U 1 1 5E536965
P 5450 4950
F 0 "#PWR?" H 5450 4800 50  0001 C CNN
F 1 "+5V" H 5465 5123 50  0000 C CNN
F 2 "" H 5450 4950 50  0001 C CNN
F 3 "" H 5450 4950 50  0001 C CNN
	1    5450 4950
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x02_Female J?
U 1 1 5E54132B
P 5150 5200
F 0 "J?" H 5122 5177 50  0001 R CNN
F 1 "Conn_01x05_Male" H 5123 5132 50  0001 R CNN
F 2 "" H 5150 5200 50  0001 C CNN
F 3 "~" H 5150 5200 50  0001 C CNN
	1    5150 5200
	1    0    0    1   
$EndComp
$Comp
L Connector:Conn_01x02_Male J?
U 1 1 5E54136F
P 5150 5200
F 0 "J?" H 5178 5180 50  0001 L CNN
F 1 "Conn_01x05_Female" H 5177 5135 50  0001 L CNN
F 2 "" H 5150 5200 50  0001 C CNN
F 3 "~" H 5150 5200 50  0001 C CNN
	1    5150 5200
	1    0    0    1   
$EndComp
Wire Wire Line
	5350 5100 5450 5100
Wire Wire Line
	5450 5100 5450 4950
$Comp
L power:GND #PWR?
U 1 1 5E54BF0A
P 5450 5300
F 0 "#PWR?" H 5450 5050 50  0001 C CNN
F 1 "GND" H 5455 5127 50  0000 C CNN
F 2 "" H 5450 5300 50  0001 C CNN
F 3 "" H 5450 5300 50  0001 C CNN
	1    5450 5300
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 5200 5450 5200
Wire Wire Line
	5450 5200 5450 5300
Wire Wire Line
	4650 5200 4650 5800
Wire Wire Line
	5600 5800 4650 5800
Connection ~ 4650 5800
Wire Wire Line
	4650 5800 4650 6300
Text Notes 3300 5450 0    50   ~ 0
Orange
Text Notes 4650 5100 0    50   ~ 0
Yellow
Text Notes 4650 5200 0    50   ~ 0
Black
Text Notes 3300 1100 0    50   ~ 0
Yellow
Text Notes 3300 1200 0    50   ~ 0
Black
Text Notes 2650 1100 0    50   ~ 0
Brown
Text Notes 2650 1200 0    50   ~ 0
Bleu
Text Notes 5000 3650 0    50   ~ 0
Bleu
Wire Bus Line
	7400 2950 7400 6200
$EndSCHEMATC
