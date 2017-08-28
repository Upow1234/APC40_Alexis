//last updated 8/27/2017, added slew and saving knob positions
// ****USE ESCAPE KEY TO SAVE KNOB POSITIONS!!!!**** \\

import themidibus.*;
import java.util.Map;

MidiBus controllerBus;
MidiBus outputBus;

APC40Page[] page = new APC40Page[4];

int pageSelection = 0;

int[] videoSelection = new int[6];

float slewRate = 1;
float slewRateMin = 0.1;
float slewRateMax = 5;

Table savedPositions;

float[] faderDestination = new float[9];
float[] faderCurrentValue = new float[9];

void setup() {
  size(200, 200);

  //uncomment the line below to print a list of midi inputs and outputs
  MidiBus.list();

  controllerBus = new MidiBus(this, "Akai APC40", "Akai APC40");
  outputBus = new MidiBus(this, -1, "To Ableton"); //MAX to Resolume


  savedPositions = loadTable("savedKnobPositions.csv", "header"); //table to load saved knob positions

  for (int i = 0; i < 4; i++) {
    page[i] = new APC40Page(i, i);
  }

  for (int i = 0; i < videoSelection.length; i++) {
    videoSelection[i] = -1;
  }

  pageSelection = 0;

  controllerBus.sendNoteOn(0, 87, 1);
  controllerBus.sendNoteOn(0, 88, 0); 
  controllerBus.sendNoteOn(0, 89, 0); 
  controllerBus.sendNoteOn(0, 90, 0);

  page[pageSelection].outputPageIndicators(pageSelection);
}

void draw() {

  for (int p = 0; p < 4; p++) {
    for (int i = 0; i < 16; i++) {
      page[p].changeOnSlew(i);
    }
  }

  for (int i = 0; i < faderDestination.length; i++) {
    slewFader(i);
  }
}

void noteOn(int channel, int pitch, int velocity) {
  /*
  println();
   println("Note On:");
   println("--------");
   println("Channel:"+channel);
   println("Pitch:"+pitch);
   println("Velocity:"+velocity);*/

  if ((pitch >= 52) && (pitch <= 57)) {

    if (videoSelection[pitch - 52] == channel) {
      for (int i = 0; i < 8; i++) {
        controllerBus.sendNoteOn(i, pitch, 0);
        videoSelection[pitch - 52] = -1;
      }
    } else {

      videoSelection[pitch - 52] = channel;

      for (int i = 0; i < 8; i++) {
        controllerBus.sendNoteOn(i, pitch, 0);
      }

      controllerBus.sendNoteOn(channel, pitch, 3);
    }

    outputBus.sendNoteOn(channel, pitch, velocity);
  } else if (pitch == 87) {
    pageSelection = 0;

    controllerBus.sendNoteOn(0, 88, 0); 
    controllerBus.sendNoteOn(0, 89, 0); 
    controllerBus.sendNoteOn(0, 90, 0);

    page[pageSelection].outputPageIndicators(pageSelection);
    println("Page Selection = " + pageSelection);
  } else if (pitch == 88) {
    pageSelection = 1;

    controllerBus.sendNoteOn(0, 87, 0); 
    controllerBus.sendNoteOn(0, 89, 0); 
    controllerBus.sendNoteOn(0, 90, 0);

    page[pageSelection].outputPageIndicators(pageSelection);
    println("Page Selection = " + pageSelection);
  } else if (pitch == 89) {
    pageSelection = 2;
    controllerBus.sendNoteOn(0, 87, 0); 
    controllerBus.sendNoteOn(0, 88, 0); 
    controllerBus.sendNoteOn(0, 90, 0);

    page[pageSelection].outputPageIndicators(pageSelection);
    println("Page Selection = " + pageSelection);
  } else if (pitch == 90) {
    pageSelection = 3;

    controllerBus.sendNoteOn(0, 87, 0); 
    controllerBus.sendNoteOn(0, 88, 0); 
    controllerBus.sendNoteOn(0, 89, 0);

    page[pageSelection].outputPageIndicators(pageSelection);
    println("Page Selection = " + pageSelection);
  } else {
    println("Other---  Channel = " + channel + "  Pitch = " + pitch + "  velocity = " + velocity);
    outputBus.sendNoteOn(channel, pitch, velocity);
  }
}

void noteOff(int channel, int pitch, int velocity) {
  /*println();
   println("Note Off:");
   println("--------");
   println("Channel:"+channel);
   println("Pitch:"+pitch);
   println("Velocity:"+velocity);*/

  if ((pitch >= 52) && (pitch <= 57)) {

    if (videoSelection[pitch - 52] == -1) {
    } else {
      controllerBus.sendNoteOn(channel, pitch, 2);
    }
  } 

  if ((pitch >= 87) && (pitch <= 90)) {
  } else {
    outputBus.sendNoteOff(channel, pitch, velocity);
  }
}

void controllerChange(int channel, int number, int value) {

  if (number == 7) { //normal fader
    faderDestination[channel] = value;
  } else if (number == 14) { //master fader
    slewRate = map(value, 0, 127, slewRateMin, slewRateMax);
    println("Slew Rate = " + slewRate);
  } else if (number == 15) { //cross fader
    faderDestination[8] = value;
  } else if (number == 47) {
    outputBus.sendControllerChange(channel, number, value);
    println("Tempo Knob---  Channel = " + channel + "  Number = " + number + "  value = " + value);
  } else {
    page[pageSelection].setDestination(number, value);
  }
}

void slewFader(int faderNumber) {

  if (faderDestination[faderNumber] > faderCurrentValue[faderNumber]) {

    if (faderCurrentValue[faderNumber] + slewRate > faderDestination[faderNumber]) {

      faderCurrentValue[faderNumber] = faderDestination[faderNumber];
    } else {

      faderCurrentValue[faderNumber] = faderCurrentValue[faderNumber] + slewRate;
    }

    if (faderNumber == 8) {
      outputBus.sendControllerChange(0, 15, int(faderCurrentValue[faderNumber]));
      println("Cross Fader---  Channel = 0   Number = 15   value = " + faderCurrentValue[faderNumber]);
    } else {
      outputBus.sendControllerChange(faderNumber, 7, int(faderCurrentValue[faderNumber]));
      println("Fader--- Number = " + faderNumber + "  value = " + faderCurrentValue[faderNumber]);
    }
  }

  if (faderDestination[faderNumber] < faderCurrentValue[faderNumber]) {

    if (faderCurrentValue[faderNumber] + (slewRate * -1) < faderDestination[faderNumber]) {

      faderCurrentValue[faderNumber] = faderDestination[faderNumber];
    } else {

      faderCurrentValue[faderNumber] = faderCurrentValue[faderNumber] + (slewRate * -1);
    }

    if (faderNumber == 8) {
      outputBus.sendControllerChange(0, 15, int(faderCurrentValue[faderNumber]));
      println("Cross Fader---  Channel = 0   Number = 15   value = " + faderCurrentValue[faderNumber]);
    } else {
      outputBus.sendControllerChange(faderNumber, 7, int(faderCurrentValue[faderNumber]));
      println("Fader--- Number = " + faderNumber + "  value = " + faderCurrentValue[faderNumber]);
    }
  }
}

void keyPressed() { //saves knob positions on pressing esc key and closes sketch
  if (keyCode == 27) {

    for (int p = 0; p < 4; p++) {
      page[p].saveToTable();
    }
  }

  saveTable(savedPositions, "data/savedKnobPositions.csv");

  println("Knob Positions Have Been Saved!");
}