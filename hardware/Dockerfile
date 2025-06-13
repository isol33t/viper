ARG WORK_PATH=/keyboard
ARG PROJECT_NAME=viper

# FROM admwscki/kicad-kbplacer-primary:9.0.2-jammy as debug
FROM admwscki/kicad-kbplacer-primary:9.0.2-jammy

# this revision has been used when [1] has been written
# [1] https://adamws.github.io/keyboard-pcb-design-with-ergogen-and-kbplacer/
ARG KBPLACER_REVISION=ca69cbc0f1de216fd50f63ba26180ad683a91270

ARG KICAD_3RDPARTY_PATH=/root/.local/share/kicad/9.0/3rdparty
ARG WORK_PATH
ARG PROJECT_NAME

ARG SWITCH_LIBRARY=com_github_perigoso_keyswitch-kicad-library

RUN apt-get update \
  && apt-get install -y openscad xdotool x11-xserver-utils x11-apps zip

ENV DISPLAY=:99
ENV XAUTHORITY=/root/.Xauthority

RUN touch $XAUTHORITY && chmod 600 $XAUTHORITY

# install 3rdparty footprints
RUN mkdir -p $KICAD_3RDPARTY_PATH
RUN cd $KICAD_3RDPARTY_PATH \
  && mkdir -p footprints \
  && mkdir tmp && cd tmp \
  && wget https://github.com/kiswitch/keyswitch-kicad-library/releases/download/v2.4/keyswitch-kicad-library.zip \
  && echo "b38d56323acb91ad660567340ca938c5b4a83a27eea52308ef14aa7857b0071b keyswitch-kicad-library.zip" | sha256sum -c \
  && unzip keyswitch-kicad-library.zip \
  && rm keyswitch-kicad-library.zip \
  && mv footprints ../footprints/$SWITCH_LIBRARY \
  && cd .. && rm -rf tmp

RUN mkdir -p $WORK_PATH

RUN python3 -m pip install hatch

# RUN python3 -m pip install git+https://github.com/adamws/kle2netlist.git@develop@2f6d8a0cc9a103a2b63d162d1e4ccd297c489682
# RUN python3 -m pip install git+https://github.com/adamws/kle2netlist.git@develop

# Use 3x 0.1u & 1x 10u decoupling capacitors
# Set ref for Reset button to RST1
COPY kle2netlist-decoupling-rst.patch $WORK_PATH/

RUN git clone https://github.com/adamws/kle2netlist.git \
 && cd kle2netlist \
 && git checkout develop \
 && git apply $WORK_PATH/kle2netlist-decoupling-rst.patch \
 && python3 -m pip install .

RUN git clone https://github.com/adamws/kicad-kbplacer.git \
  && cd kicad-kbplacer \
  && git checkout $KBPLACER_REVISION \
  && python3 -m pip install .

COPY kle/keyboard-layout-via-10u.json $WORK_PATH/keyboard-layout-via-10u.json

WORKDIR $WORK_PATH

COPY template.kicad_pro $WORK_PATH/$PROJECT_NAME.kicad_pro
RUN sed -i 's/template\.kicad_pro/$PROJECT_NAME\.kicad_pro/g' $PROJECT_NAME.kicad_pro

RUN python3 -m kbplacer.kle_serial \
  -in keyboard-layout-via-10u.json -inform KLE_VIA \
  -outform KLE_RAW -collapse -out $PROJECT_NAME-kle.json

# fix labels (to be fixed in kbplacer)
# RUN sed -i 's/[RC]//g' $PROJECT_NAME-kle.json

# hacky patch to create led matrix
# requires manual work, remove all labels
# connect all columns, add vnc
# connect all rows, add gnd
# separate caps led
# LED_SMD:LED_0201_0603Metric is a placeholder
# https://github.com/kiswitch/kiswitch/pull/40
# replace with MX/Alps compatible led, maybe from ai03-2725/MX_V2,
# Switch_Misc.pretty/MX-LED-PolarityMarked.kicad_mod
# extract netlist of led matrix, merge somehow?
# pcbnew can append a board

COPY kicad-kbplacer-led.patch $WORK_PATH/kicad-kbplacer-led.patch

RUN cd /kicad-kbplacer && \
  git apply $WORK_PATH/kicad-kbplacer-led.patch \
  && hatch run tools:layout2schematic -in $WORK_PATH/$PROJECT_NAME-kle.json \
  -out $WORK_PATH/$PROJECT_NAME-switch-matrix.kicad_sch -f \
  -swf "locallib:SW_Hybrid_Cherry_MX_Alps_1.00u" \
  -df "Diode_SMD:D_0805_2012Metric_Pad1.15x1.40mm_HandSolder" \
  && hatch run tools:layout2ledschematic -in $WORK_PATH/$PROJECT_NAME-kle.json \
  -out $WORK_PATH/$PROJECT_NAME-led-matrix.kicad_sch -f \
  -rf "Resistor_SMD:R_0805_2012Metric" \
  -df "Switch_Misc:MX-LED-PolarityMarked"

# this is required, otherwise netlist will contain many 'unconnected' pads
# is this required with kle2netlist?
# might as well, to use as hierarchical sheets
COPY eeschema-open-and-save.sh $WORK_PATH
RUN xvfb-run ./eeschema-open-and-save.sh $PROJECT_NAME-switch-matrix.kicad_sch
RUN xvfb-run -a ./eeschema-open-and-save.sh $PROJECT_NAME-led-matrix.kicad_sch

# RUN kicad-cli sch export netlist --output $PROJECT_NAME.net $PROJECT_NAME.kicad_sch
RUN kle2netlist --layout $WORK_PATH/$PROJECT_NAME-kle.json --netlist-output $PROJECT_NAME.net \
  --lib-path /usr/share/kicad/symbols \
  --diode-footprint "Diode_SMD:D_0805_2012Metric_Pad1.15x1.40mm_HandSolder" \
  --switch-footprint "locallib:SW_Hybrid_Cherry_MX_Alps_1.00u" \
  --stabilizer-footprint "Mounting_Keyboard_Stabilizer:Stabilizer_Cherry_MX_{:.2f}u" \
  --controller-circuit atmega32u4,v2 \
  --extra-circuits usb,udb_clone \
  --row-column-pin-order "PB1,PB2,PB3,PF0,PF1,PF4,PF7,PF5,PF6,PC7,PC6,PB6,PB5,PB4,PD7,PD6,PD4,PD5,PD3,PB7"

  # --row-column-pin-order "PB6,PB5,PB4,PD7,PE6,PD2,PD1,PD3,PD5,PD4,PD6,PC6,PF0,PF1,PF4,PF5,PF6,PF7,PC7,PB7"
  # --row-column-pin-order "PB1,PB2,PB3,PF0,PF1,PF4,PF7,PF5,PF6,PC7,PC6,PB6,PB5,PB4,PD7,PD6,PD4,PD5,PD3,PB7" # voyager based with additional columngit

COPY viper/locallib.pretty $KICAD_3RDPARTY_PATH/footprints/locallib.pretty

RUN kinet2pcb -i $PROJECT_NAME.net \
  --libraries /usr/share/kicad/footprints \
              $KICAD_3RDPARTY_PATH/footprints/locallib.pretty \
              $KICAD_3RDPARTY_PATH/footprints/$SWITCH_LIBRARY/Mounting_Keyboard_Stabilizer.pretty \
  --output $PROJECT_NAME.kicad_pcb

RUN python3 -m kbplacer --board $PROJECT_NAME.kicad_pcb \
  --layout $PROJECT_NAME-kle.json \
  --diode "D{} CUSTOM 5.08 4 90 BACK" \
  --optimize-diodes-orientation \
  # --route-switches-with-diodes \
  # --route-rows-and-columns
  --log-level DEBUG > $PROJECT_NAME.log 2>&1 

RUN kicad-cli pcb export svg --exclude-drawing-sheet \
  -l F.Cu,B.Cu,F.Silkscreen -o $PROJECT_NAME.svg $PROJECT_NAME.kicad_pcb

RUN zip -r $PROJECT_NAME.zip \
  $PROJECT_NAME-kle.json \
  $PROJECT_NAME.log \
  $PROJECT_NAME-switch-matrix.kicad_sch \
  $PROJECT_NAME-led-matrix.kicad_sch \
  $PROJECT_NAME.kicad_sch \
  $PROJECT_NAME.kicad_pcb \
  $PROJECT_NAME.net \
  $PROJECT_NAME.svg

# plate generation with 1.5u cutouts doesn't work
# maybe look into exporting edgecuts as svg
# sanity check for plate generation tool
# COPY generate-plate.sh $WORK_PATH
# RUN xvfb-run -a ./generate-plate.sh $KBPLACER_REVISION

FROM scratch
ARG WORK_PATH
ARG PROJECT_NAME
COPY --from=0 $WORK_PATH/$PROJECT_NAME.zip .
