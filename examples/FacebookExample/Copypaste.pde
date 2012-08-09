// //////////////////
// Clipboard class for Processing
// by seltar
// modified by adamohern for mac
// modified by achang (nytlabs) for oauthP5 examples
//
// v 0115AO
// only works with programs. applets require signing


import java.awt.datatransfer.*;
import java.awt.Toolkit; 

// detect multiple keypresses by storing them in a global array
boolean[] keys = new boolean[526];

boolean checkKey(int k)
{
  if (keys.length >= k) {
    return keys[k];
  }
  return false;
}

// Copypaste class definition

class Copypaste {

  Clipboard clipboard;

  Copypaste() {
    getClipboard();
  }

  void getClipboard () {
    // this is our simple thread that grabs the clipboard
    Thread clipThread = new Thread() {
      public void run() {
        clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
      }
    };

    // start the thread as a daemon thread and wait for it to die
    if (clipboard == null) {
      try {
        clipThread.setDaemon(true);
        clipThread.start();
        clipThread.join();
      }  
      catch (Exception e) {
      }
    }
  }

  void copyString (String data) {
    copyTransferableObject(new StringSelection(data));
  }

  void copyTransferableObject (Transferable contents) {
    getClipboard();
    clipboard.setContents(contents, null);
  }

  String pasteString () {
    String data = null;
    try {
      data = (String)pasteObject(DataFlavor.stringFlavor);
    }  
    catch (Exception e) {
      System.err.println("Error getting String from clipboard: " + e);
    }
    return data;
  }

  Object pasteObject (DataFlavor flavor) throws UnsupportedFlavorException, IOException
  {
    Object obj = null;
    getClipboard();

    Transferable content = clipboard.getContents(null);
    if (content != null)
      obj = content.getTransferData(flavor);

    return obj;
  }
}

