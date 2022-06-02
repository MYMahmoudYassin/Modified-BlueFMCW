# Modified BlueFMCW:Frequency Hopping Spread Spectrum for joint Communication and Sensing Radar for Mitigation of Interference and Spoofing
In this project I present Modified Blue FMCW, which is a joint radar and communication spread spectrum system. The system is based on FSK modulating the widely used FMCW waveform by varying the starting frequency of each component chirp and hopping between various frequency ranges. Analysis have been done to show the effect of integrating the communication and radar systems together using spread spectrum on each other. Two simulations have been done, the first one for regular FHSS to show the effect of jamming on the system and how to enhance its performance. the second simulation was to show how FMCW radar works in an automotive adaptive cruise control. <br />
**This project was a part of class EE573 – DIGITAL COMMUNICATIONS II-KFUPM-spring 2022**
- Project members:
Mahmoud Yassin Mahmoud
- Submitted to:
Dr. Wessam Mesbah <br />
For more information you can check the following documentation: **"Term paper_EE573_Mahmoud Yassin"**
## Problem Statement
Security is an important factor to consider when designing an automotive radar. There are two types of automotive radar attacks.
First, future jamming attacks have the potential to cause major collisions. Attackers who use jamming intentionally send out a high-power radio signal to confuse or overwhelm the radar receiver. By saturating the radar with noise, jamming attacks render it inoperable. However, in a highly mobile environment, the damage from a jamming attack can be reduced, making it difficult for an aggressor to target vehicles.
Second, automotive radars are known to be vulnerable to spoofing, replicating, and retransmitting radar transmit signals to provide false information to the radar and corrupt received data.

## Proposed Scheme for Modified BlueFMCW:
In the modified Blue FMWC, we apply two types of frequency-hopped (FH) spread spectrum:
1. Blue FMWC within Ts duration for the radar system.
2. frequency-hopped spread spectrum communication system (FH-CS)<br />
It's noteworthy that the code that is being used for hoping for the two types are different from each other, where in the blue FMWC the code randomly permuting the sub-chirps and in the SFH-CS the other code is being made pseudo randomly according to the output from a PN generator. That was made because the need for the phase continuity in the chirp. Figure 6 shows the main idea of the proposed system.

![image](https://user-images.githubusercontent.com/106708838/171571899-2740e556-95f2-4d06-88f8-4cf09bc995a9.png)

## Simulation Results:
**The first** simulation employs an FHSS communication system with FSK and noncoherent detecting receivers. We can demonstrate the impact of FHSS against partial band jamming signals by supplying input values of 1 (with jamming) and 0 (without jamming).

![image](https://user-images.githubusercontent.com/106708838/171572290-dcfacae0-a2d9-49f7-9dd0-8c5de65d4fc4.png)

Table 2 shows the FHSS system parameters used in this simulation. When partial band jamming is enabled, jamming blanks out a fixed but randomly chosen FSK channel.
Figure 7 depicts the effect of partial band jamming on the FHSS user under additive white Gaussian channel noise. Without jamming, we can clearly observe that the FHSS performance matches that of the AWGN FSK. Performance visibly increases when partial jamming and L are increased from 4 to 8, and then to 16.

![image](https://user-images.githubusercontent.com/106708838/171572514-7b063683-6707-4f03-8b6d-8c5aa12604c8.png)

![image](https://user-images.githubusercontent.com/106708838/171572641-767569ca-d830-4246-a24c-2bd40bc4ded8.png)

**The second** simulation is an FMCW radar that estimates range and Doppler on a moving vehicle using an automotive long-range radar (LRR) model that is utilized for adaptive cruise control (ACC). This type of radar typically operates in the 77 GHz band. The radar system constantly calculates the distance between the vehicle on which it is mounted and the vehicle in front of it, alerting the driver when the two grow too close. Figure 8 depicts the working idea of ACC and table 2 summarize the system parameters.

![image](https://user-images.githubusercontent.com/106708838/171572891-d5ea2d14-e3a3-4d7d-b2a2-8c15584b6fb4.png)

![image](https://user-images.githubusercontent.com/106708838/171572975-4ddfd681-4508-4144-8980-d21cb5d9418f.png)

A car in front of it is normally the target of an ACC radar. This simulation assumes the target car is 50 meters ahead of the car with the radar, traveling at 96 kilometers per hour along the x-axis. Figure 9 shows the used FMCW signal.

![image](https://user-images.githubusercontent.com/106708838/171573130-ce197d62-7452-4831-a405-0f6ea446754f.png)

Figure 10 demonstrates that, despite the fact that the received signal is wideband
(channel 1), sweeping across the whole bandwidth causes the dechirped signal to
become narrowband (channel 2).
Figure 11 depicts the range Doppler response, which demonstrates that the
automobile in front is somewhat more than 40 m distant and seems nearly
motionless. This is predicted given that the car's radial speed relative to the radar
is only 4 km/h, or 1.11 m/s.
There are several methods for calculating the target car's range and speed. The
root MUSIC technique is used in this simulation to calculate both the beat
frequency and the Doppler shift.

![image](https://user-images.githubusercontent.com/106708838/171573319-0c70ac22-8558-4a87-9ab2-4d3abe3ef9df.png)

![image](https://user-images.githubusercontent.com/106708838/171573456-087e803e-c056-413b-a8b6-7ad30a0f7782.png)






