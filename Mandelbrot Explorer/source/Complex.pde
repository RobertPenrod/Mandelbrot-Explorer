class Complex{

  double real;
  double imaginary;
  
  Complex(){
    Set(0,0);
  }
  Complex(double r, double i){
    Set(r,i);
  }
  Complex(Complex c){
    Set(c);
  }
  
  void Set(double r, double i){
    real = r;
    imaginary = i;
  }
  
  void Set(Complex c){
    Set(c.real, c.imaginary);
  }
  
  Complex Add(Complex toAdd){
    return new Complex(real + toAdd.real, imaginary + toAdd.imaginary);
  }
  
  Complex Add(double r, double i){
    return Add(new Complex(r,i));
  }
  
  Complex Multiply(Complex mult){
    double r = (real * mult.real) - (imaginary * mult.imaginary);
    double i = (real * mult.imaginary) + (mult.real * imaginary);
    return new Complex(r,i);
  }
  
  double Magnitude(){
    return sqrt(pow((float)real,2) + pow((float)imaginary,2));
  }
  
  String ToString(){
    return real + " + i" + imaginary;
  }
  
  double[] ToArray(){
    double[] result = {real, imaginary};
    return result;
  }
  
  double distanceSquared(Complex point){
    return (float)((point.real-real)*(point.real-real) + (point.imaginary - imaginary)*(point.imaginary - imaginary));
  }
}