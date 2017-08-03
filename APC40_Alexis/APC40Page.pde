class APC40Page {

  int[] storedValues = new int[16];
  int outputChannel;

  IntDict knobNumbers = new IntDict();

  int[] controlNumbers = { 48, 49, 50, 51, 52, 53, 54, 55, 16, 17, 18, 19, 20, 21, 22, 23 };

  APC40Page(int tempOutputChannel) {

    for (int i = 0; i < storedValues.length; i++) {
      storedValues[i] = int(random(0, 127));
    }

    for (int i = 0; i < controlNumbers.length; i++) {
      knobNumbers.set(str(controlNumbers[i]), i);
    }

    outputChannel = tempOutputChannel;
  }

  void outputPageIndicators(int tempPageSelection) {

    for (int i = 0; i < 16; i++) {
      controllerBus.sendControllerChange(0, controlNumbers[i], storedValues[i]);
    }
  }

  void receiveInput(int tempNumber, int tempValue) {

    storedValues[knobNumbers.get(str(tempNumber))] = tempValue;
    
    outputBus.sendControllerChange(outputChannel, tempNumber, tempValue);
    println("Sending Control Change---  Page Selection = " + pageSelection + "  Number = " + tempNumber + "  Value = " + tempValue);

  }

}