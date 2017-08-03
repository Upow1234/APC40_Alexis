//last updated 8/3/2017

import themidibus.*;
import java.util.Map;

MidiBus controllerBus;
MidiBus outputBus;

APC40Page[] page = new APC40Page[4];

int pageSelection = 0;

int[] videoSelection = new int[6];

void setup() {
  size(200, 200);

  //uncomment the line below to print a list of midi inputs and outputs
  //MidiBus.list();

  controllerBus = new MidiBus(this, "Akai APC40", "Akai APC40");
  outputBus = new MidiBus(this, -1, "To Ableton");

  for (int i = 0; i < 4; i++) {
    page[i] = new APC40Page(i);
  }

  for (int i = 0; i < videoSelection.length; i++) {
    videoSelection[i] = -1;
  }
}

void draw() {
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
  }
  
  outputBus.sendNoteOn(channel, pitch, velocity);
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
  
  outputBus.sendNoteOff(channel, pitch, velocity);
}

void controllerChange(int channel, int number, int value) {

  if (number == 7) {
    outputBus.sendControllerChange(channel, number, value);
    println("Regular Fader---  Channel = " + channel + "  Number = " + number + "  value = " + value);
  } else if (number == 14) {
    outputBus.sendControllerChange(channel, number, value);
    println("Master Fader---  Channel = " + channel + "  Number = " + number + "  value = " + value);
  } else if (number == 15) {
    outputBus.sendControllerChange(channel, number, value);
    println("Cross Fader---  Channel = " + channel + "  Number = " + number + "  value = " + value);
  } else if (number == 47) {
    outputBus.sendControllerChange(channel, number, value);
    println("Tempo Knob---  Channel = " + channel + "  Number = " + number + "  value = " + value);
  } else {
    page[pageSelection].receiveInput(number, value);
    //println("Regular Knob---  Page = " + pageSelection + "  Channel = " + channel + "  Number = " + number + "  value = " + value);
  }
}