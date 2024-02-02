public class mechante {
  float x,y;
  int cote;
  int visible=0;
  int style=1;
  
  mechante(float _x, float _y, int _cote) {
     x = _x;
     y = _y;
     cote = _cote;
   }
   
   void display() {
     if (this.visible>0) {
       image(imagetaupe,x,y,cote,cote);
       noStroke();
     }
  }
}
