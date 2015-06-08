# register allocation:
# r0: Left ADC value / tmp
# r1: Right ADC value
# r2: Switches state
# r3: Current buttons state
# r4: Previous buttons state
# r5: Button mask
#
# [0]: Left ADC
# [1]: Right ADC
# [2]: Switches
# [3]: Buttons
# [4]: Waveform
# [5]: Phase add for ring modulator
# [6]: Amplitude
# [7]: Phase add
# [8]: Mode

r5 = 0b00001000

play:
r0 = 1
[8] = r0
r0 = [0]
r1 = [1]
r2 = [2]
[6] = r0
[7] = r1
[4] = r2
#Copy r3 in r4
r4 = r3 or r3
r3 = [3]
r3 = r3 and r5
# if btn == 0 && previous btn == 1 => setring else play
r0 = r4 or r4
bcz play
r0 = r4 and r3
bcz setring
b play


setring:
r0 = 2
[8] = r0
r0 = [0]
r2 = [2]
[5] = r0
[4] = r2
#Copy r3 in r4
r4 = r3 or r3
r3 = [3]
r3 = r3 and r5
# if btn == 0 && previous btn == 1 => setring else play
r0 = r4 or r4
bcz setring
r0 = r4 and r3
bcz play
b setring
