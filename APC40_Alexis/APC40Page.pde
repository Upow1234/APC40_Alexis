class APC40Page {

  float[] storedValues = new float[16];
  int outputChannel;

  IntDict knobNumbers = new IntDict();

  int[] controlNumbers = { 48, 49, 50, 51, 52, 53, 54, 55, 16, 17, 18, 19, 20, 21, 22, 23 };

  int[] destinationValue = new int[16];
  int pageNumber;

  APC40Page(int tempOutputChannel, int pageNumberTemp) {

    for (int i = 0; i < storedValues.length; i++) {
      storedValues[i] = savedPositions.getInt(i, pageNumberTemp);
    }

    for (int i = 0; i < controlNumbers.length; i++) {
      knobNumbers.set(str(controlNumbers[i]), i);
    }

    for (int i = 0; i < destinationValue.length; i++) {
      destinationValue[i] = int(storedValues[i]);
    }

    pageNumber = pageNumberTemp;

    outputChannel = tempOutputChannel;
  }

  void outputPageIndicators(int tempPageSelection) {

    for (int i = 0; i < 16; i++) {
      controllerBus.sendControllerChange(0, controlNumbers[i], int(storedValues[i])); //is hard coding 0 here wrong???
    }
  }

  void changeOnSlew(int tempNumber) {

    //int knob = knobNumbers.get(str(tempNumber));
    int knob = tempNumber;

    if (destinationValue[knob] > storedValues[knob]) {

      if (storedValues[knob] + slewRate > destinationValue[knob]) {

        storedValues[knob] = destinationValue[knob];

        outputBus.sendControllerChange(outputChannel, tempNumber, int(storedValues[knob]));
        println("Sending Control Change---  Page Number = " + pageNumber + "  Number = " + tempNumber + "  Value = " + storedValues[knob]);
      } else {

        storedValues[knob] = storedValues[knob] + slewRate;

        outputBus.sendControllerChange(outputChannel, tempNumber, int(storedValues[knob]));
        println("Sending Control Change---  Page Number = " + pageNumber + "  Number = " + tempNumber + "  Value = " + storedValues[knob]);
      }
    }

    if (destinationValue[knob] < storedValues[knob]) {

      if (storedValues[knob] + (slewRate * -1) < destinationValue[knob]) {

        storedValues[knob] = destinationValue[knob];

        outputBus.sendControllerChange(outputChannel, tempNumber, int(storedValues[knob]));
        println("Sending Control Change---  Page Number = " + pageNumber + "  Number = " + tempNumber + "  Value = " + storedValues[knob]);
      } else {

        storedValues[knob] = storedValues[knob] + (slewRate * -1);

        outputBus.sendControllerChange(outputChannel, tempNumber, int(storedValues[knob]));
        println("Sending Control Change---  Page Number = " + pageNumber + "  Number = " + tempNumber + "  Value = " + storedValues[knob]);
        ;
      }
    }
  }

  void setDestination(int tempNumber, int destinationTemp) {

    destinationValue[knobNumbers.get(str(tempNumber))] = destinationTemp;
  }

  void saveToTable() {

    for (int i = 0; i < storedValues.length; i++) {
      savedPositions.setInt(i, pageNumber, destinationValue[i]);
    }
    
  }
}