# Duck Viper v1 - Design Notes

*Consolidated notes and research for the Duck Viper v1 PCB project*

## Design Decision Log

- 2025-05: restart PCB project
- - manual placement of basic viper pcb, no leds
- - discovered adamws/kicad-kbplacer
- - forked [4pplet/eagle_viper_rep_rev_b](https://adamws.github.io/keyboard-pcbs/#4pplet-eagle_viper_rep_rev_b)
- 2025-06:
- - added ws2818b leds
- - removed iso enter/split left shift
- - considering split hhkb layout
- - - requires qfn instead of qfp
- footprint placement
- - voyager60 usb-c
- - voyager60 qfn 
- - gh60 qfp
- [decoupling cap placement](https://components101.com/articles/decoupling-capacitor-vs-bypass-capacitors-working-and-applications)
- - The positioning involves two different capacitors, consider a capacitor of capacitance 10µF placed away from the IC which is used to smooth out the low frequency changes in the power supply and a 0.1 µF capacitor kept closer to the IC which is used to smooth the high frequency changes in the power supply.
- - 10µF placed away
- - .1µF close to pins
- - for voyager60: move 10µF cap further away
- - add additional .1µF cap where 10µF currently sits
- improve kicad docs
- nice template, https://github.com/nguyen-v/KiCAD_Templates/tree/master
- - eeschema
- - https://www.youtube.com/watch?v=_ZjyeltLMAg
- - pcbnew
- - https://www.youtube.com/watch?v=_ZjyeltLMAg&list=WL&index=109&t=1305s

You probably shouldn't connect the USB shield to GND, or if you do it should be through a cap and something like a 10M resistor. This is to avoid emitting unwanted RFI.
!
https://geekhack.org/index.php?topic=48851.msg2356672#msg2356672

- jp60
- - usb-c shield to earth, earth to ferrite bead to gnd
- tsuki
- - usb-c shield to junction, 1 to 4.7nF cap then gnd, another to 1M resistor then GND
- - no ferrite bead
- - mounting hole to case ESD
- - case mounting hole ESD to junction, 1 to 4.7nF cap then gnd, another to 1M resistor then GND
- https://geekhack.org/index.php?topic=48851.msg2361099#msg2361099
- - bpiphany: For the USB shield there seem to be as many different recommendations as there are possible ways to combine resistor/capacitor/inductor networks or directly tie it to GND or floating. It's hard to tell what to use when/where/why.
- ground plane crystal: https://geekhack.org/index.php?topic=48851.msg2406698#msg2406698
- - I think it's more about keeping the "noise" from the oscillator away from the plane. You ideally want to surround the oscillator circuit with ground, on the sides and below. You then connect this "cage" at a single point to the board ground plane.
- resistors for usb close to usb or mcu?
- - https://geekhack.org/index.php?topic=48851.msg2481179#msg2481179
- - ESD/EMI protection deivces should be placed near USB receptacle while termination(impedance matcning) resistors should be placed near controller.
- - We already know empirically that it doesn't matter very much for keyboards, though, this simple design guide will be still helpful for us.


## Component Sourcing

I found a box of components, from a previous attempt, based on [evyd13/plain60-c](https://github.com/evyd13/plain60-c#bill-of-materials-bom), yet some are currently out ot stock.

- Stick with 0805 packages
- Asian brands are Okay
- x7r capacitors are preferred
- ... by a single brand, possibly hre?
- - uniroyal
- - nexperia
- - https://www.lcsc.com/supplier/featured-asian-brands
- - qfp https://www.lcsc.com/product-detail/Microcontrollers-MCU-MPU-SOC_Microchip-Tech-ATMEGA32U4-AU_C44854.html
- - qfn https://www.lcsc.com/product-detail/Microcontroller-Units-MCUs-MPUs-SOCs_Microchip-Tech-ATMEGA32U4-MU_C112161.html

## Quick Reference

### Key Decisions
- **Layout**: Split HHKB (requires QFN placement between Caps Lock and A)
- **Components**: 0805 package (already sourced but wrong dimensions, currently using SOD123 & QFP)
- **Connector**: USB-C (seems to fit!)
- **Microcontroller**: ATmega32U4 (QFN vs QFP decision pending)
- **Reference Design**: Tsuki, JP60, Voyager60, plain60-b/c

### Current Status
- ✅ Dev environment setup (Mac + Linux + Docker)
- ✅ KLE layouts created (collapsed/uncollapsed variants)
- ✅ Kbplacer and kle2netlist working
- ✅ Local library Git repo created
- ⚠️ **QFN prototyping cost: ~$17.60 per PCB** (PCBWay assembly)
- 🔄 Library decisions pending (Acheron vs others)
- 🔄 ESD protection component selection

---

## Development Environment ✅

### Tools Setup
- **Mac**: Python venv with kbplacer, pyyaml, pyurlon, kle2netlist
- **Linux**: KiCad global python modules + Docker support
- **Kbplacer**: Working with dockerized dev branch
- **Kle2netlist**: Integrated with ATmega template

### Workflows Tested
- ✅ Manual kbplacer-kicad workflow
- ✅ Dockerized development environment
- ✅ KLE → netlist → KiCad pipeline

---

## Layout & Mechanical ✅

### KLE Layouts Complete
- **Uncollapsed**: Raw, Internal, Via variants
- **Collapsed**: Raw, Internal variants
- **Screenshots and URLs**: Documented
- **Stepped Caps**: Measured and positioned
  - Regular to stepped caps offset: -4.7625mm
  - Stepped caps to edge: 11.58125mm
  - Grave (`) to stepped caps: x+2.38125, y+38.1

### PCB Outline Placement ✅
- **Position relative to K_TILDE**: X=133.35, Y=38.085
- **PCB Dimensions**: 285mm × 94.6mm

### Stabilizer Configuration
- **Normal**: Backspace
- **Flipped 180°**: Space, LShift, RShift, Enter
- **ISO**: ST28_1 270° (conflicts with WS2812B LED placement)

---

## Component Research

https://www.lcsc.com/product-detail/Diodes-ESD_STMicroelectronics_USBLC6-2SC6_USBLC6-2SC6_C7519.html


### Microcontroller Package Decision
**QFN (Current Choice):**
- ✅ Required for split HHKB (fits between Caps & A)
- ❌ Can't hand solder easily
- ❌ Assembly cost: $17.60 per PCB (5 PCBs via PCBWay)
- ✅ 5 QFN ATmegas already sourced

**QFP Alternative:**
- ✅ Hand solderable
- ❌ May not fit split HHKB layout constraints

### Component Packages & Sourcing
**Current Stock (Wrong Dimensions):**
- 0805 capacitors ✅
- 0805 resistors ✅
- USB-C connector ✅ (seems to fit!)
- 5× QFN ATmega32U4 ✅

**Component Updates Needed:**
- Update footprints from current to 0805
- All non-LED board parts sourced but need dimension fixes

### ESD Protection Options
**USBLC6-2SC6** (Current stock):
- Very low capacitance ESD protection
- STMicroelectronics part

**PRTR5V0U2X** (JP60 reference):
- Ultra low capacitance double rail-to-rail protection
- Nexperia part

**TPD2S017** (kle2netlist template):
- 2-channel 5.5V, 1pF, ±11kV protection with EMI filtering
- TI part

---

## Library Decisions (Pending)

### Symbol Libraries
- **Acheron**: Selected ✅
- Reference components from Tsuki schematic:
  - ResistorSMD 0603_1608Metric
  - CapSMD 0603
  - ATQFP44_10x10mm_P0.8
  - Crystal_SMD_3225-4Pin
  - SW_SPST_TL3342
  - SOT-23-6 ESD
  - USB_C_Receptacle_XKB_U262-16XN-4BVC11

### Footprint Libraries (To Decide)
- **Acheron**: Connectors, mounting holes
- **Kiswitch**: Connectors, stabilizers  
- **MX_V2**: Switch LEDs
- **Local lib**: Viper outline ✅

### Local Library ✅
- Viper outline ✅
- ISP header (needed? QMK has soft reset)
- Crystal (custom 3-pad vs 4-pad - why?)
- Mounting holes (Acheron reference)
- USB connectors

---

## LED Matrix & RGB

### Switch LEDs ✅
- Circuit tested with old Viper repo
- Separate circuit for Caps Lock LED planned

### RGB LEDs (WS2812B)
**Component**: TZ_3528S2RGB_5V (JLCPCB: C26159669)
- 3528 format footprint
- **Conflict**: ISO Enter OR RGB LEDs (choosing RGB)
- Reference circuits: Tsuki, Voyager
- VCC/VDD/5V power considerations

### LED Matrix Integration ✅
- Successfully added 2x2 LED matrix to test
- ATmega template integration working

---

## Manufacturing Planning

### Assembly Costs
- **QFN Assembly**: $88 for 5 PCBs (PCBWay) = $17.60 each
- Cost excludes MCU component cost
- QFN hand soldering attempted but challenging

### PCB Specifications
- **Connector**: USB-C (fits in current design)
- **ESD**: Update schematic for chosen component
- **Finish**: Research Viper/Sprit/GH60 comparisons needed

---

## Future Features & Improvements

### Planned Features
- **MX Lock Caps**: LED support (reference: GH60PCB)
- **STM32 Variants**: Joker48/64 circuitry reference
- **Split HHKB**: Additional layout exploration

### Key Mapping & Special Keys
**Flipped Keys** (from bad/viper_v1):
- KC_GRV, KC_1, KC_2, KC_Q
- KC_CAPS, KC_CAPS_STEP, KC_A, KC_H
- KC_SHIFT, KC_SHIFT_SHORT, KC_ISO, KC_Z
- KC_SPACE, KC_RIGHT_ALT

---

## Completed Tasks ✅

### Development Setup
- [x] Local lib Git repo
- [x] Viper outline
- [x] ISP header
- [x] Cleanup repos (Viper, Voyager, Keebio, GH60, STM32 LED matrix)
- [x] Dev environment (Mac + Linux)
- [x] KLE layouts (all variants)
- [x] Kbplacer-KiCad integration
- [x] LED matrix testing
- [x] 2x2 test PCB with LED matrix + ATmega template

### Measurements & Positioning
- [x] Stepped caps measurements and positioning
- [x] PCB outline placement calculations
- [x] Key matrix positioning

---

## Pending Tasks

### Critical Path
- [ ] Finalize library decisions (Acheron vs alternatives)
- [ ] Test libraries in dockerized environment
- [ ] Complete RGB LED integration (non-ISO)
- [ ] Stabilizer placement (normal + flipped orientations)
- [ ] Component dimension updates (0805 transition)

### Secondary
- [ ] Schematic verification (community help needed)
- [ ] USB D+/D- net naming
- [ ] ATmega pin assignments optimization
- [ ] Assembly cost optimization research

---

## References & Resources

### Key Projects
- **Tsuki**: Primary schematic reference ⭐
- **Voyager60**: QFN placement reference
- **Keebio**: Component references
- **GH60**: Finish comparisons

### Tools & Documentation
- [Keyboard PCB Design Guide](https://adamws.github.io/keyboard-pcb-design-with-ergogen-and-kbplacer/)
- [KLE](https://www.keyboard-layout-editor.com)
- [KLE Converter](https://keyboard-tools.xyz/kle-converter)
- [kle2netlist](https://github.com/adamws/kle2netlist/tree/develop)
- [Via Layout Docs](https://www.caniusevia.com/docs/layouts/)
- [AI03 PCB Design Wiki](https://wiki.ai03.com/books/pcb-design/page/microcontroller-design)
- [Kbplacer Annotation Guide](https://github.com/adamws/kicad-kbplacer/blob/master/docs/annotation_guide.md)
- [masterzen design guide](https://www.masterzen.fr/2020/05/03/designing-a-keyboard-part-1/)