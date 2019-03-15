ArrayList<Tree> trees = new ArrayList<Tree>();

ArrayList<PhysicsObj> processees = new ArrayList<PhysicsObj>();
ArrayList<PhysicsObj> renderees = new ArrayList<PhysicsObj>();

float gravity = 1.0;
float airFriction = 0.001;
float groundFriction = 0.7;

float mouse_acc_x = 0.05; 
float mouse_acc_y = 0.05;

float wind_acc_x = 0.0;
float wind_acc_y = 0.0;

int max_grown_times = 10; // Default: 10.
int min_grown_length = 8; // Default: 8.

int max_random_drops = 300;
int random_drops = max_random_drops;
int unique_raindrop_number = 0;

float dt = 1.0;

float background_hue = 0.0;
float background_satur = 0.0;
float background_light = 0.0;

HScrollbar hs1;
HScrollbar hs2;
HScrollbar hs3;
HScrollbar hs4;
HScrollbar hs5;

Tree tree;

Sun sun;
Moon moon;

void setup()
{
  size(800, 800);
  colorMode(HSB, 360.0, 100.0, 100.0, 100.0);

  hs1 = new HScrollbar(0, 12, width, 16, 16, true);
  hs2 = new HScrollbar(0, 34, width, 16, 16, true);
  hs3 = new HScrollbar(0, 56, width, 16, 16, true);
  hs4 = new HScrollbar(0, 78, width, 16, 16, false);
  hs5 = new HScrollbar(0, 100, width, 16, 16, false);

  sun = new Sun();
  moon = new Moon();

  for(int i = 0; i < max_random_drops; i++)
  {
    new Drop(new PVector());
  }

  colorMode(HSB);
  tree = new Tree(width / 2, height);
  //trees.add(new Tree(width / 2, height));
}

void draw()
{
  background_hue = min(210.0, map(sun.hue, 30.0, 50.0, sun.hue, 210.0));
  background_satur = min(50.0, sun.Light);
  background_light = min(82.0, sun.Light + moon.Light);
  background(background_hue, background_satur, background_light);

  /*
  pmouseX = pclientX;
  pmouseY = pclientY;
  mouseX = clientX;
  mouseY = clientY;
  mousePressed = pressedMouse;
  hslSetColor(background_hue, background_satur, background_light);
  */

  sun.drawSelf();
  moon.drawSelf();

  tree.grow();

  wind_acc_x = map(hs4.getPos(), 1.0, width, -10.0, 10.0);

  random_drops = round(map(hs5.getPos(), 1.0, width, 0.0, max_random_drops));

  for(int i = processees.size() - 1; i >= 0; i--)
  {
    PhysicsObj physics_obj = processees.get(i);
    physics_obj.process();
  }

  for(int i = renderees.size() - 1; i >= 0; i--)
  {
    PhysicsObj render_obj = renderees.get(i);
    render_obj.render();
  }

  hs1._update();
  hs2._update();
  hs3._update();
  hs4._update();
  hs5._update();
  hs1.display();
  hs2.display();
  hs3.display();
  hs4.display();
  hs5.display();

/*
  for(Tree tree : trees)
  {
    tree.drawSelf();
    tree.grow();
  }
*/
}

class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  boolean update;

  HScrollbar (float xp, float yp, int sw, int sh, int l, boolean update) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
    this.update = update;
  }

  void _update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
      if(this.update)
      {
        tree.Del();
        tree = new Tree(width / 2, height);
      }
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(0.0, 0.0, 80.0);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(0.0, 0.0, 0.0);
    } else {
      fill(0.0, 0.0, 40.0);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}

class Branch extends PhysicsObj
{
  PVector start;
  PVector end;
  PVector default_end;
  color Color = color(30.0, 110.0, 110.0);

  Tree source;
  boolean is_root = false;

  float default_len = 0.0;

  float friction = 0.1;

  float angle = PI / 8;
  float length_loss = 0.67;

  ArrayList<Branch> sub_branches = new ArrayList<Branch>();
  ArrayList<Leaf> my_leaves = new ArrayList<Leaf>();

  Branch(PVector start, PVector end)
  {
    this.start = start;
    this.end = end;
    this.default_end = new PVector();
    this.default_end.set(this.end);

    this.default_len = PVector.sub(this.end, this.start).mag();

    processees.add(this);
    renderees.add(this);

    length_loss = map(hs2.getPos(), 1.0, width, 0.1, 0.7);
    angle = map(hs3.getPos(), 1.0, width, 0.0, PI / 2);
  }

  void grow(Tree source)
  {
    PVector dir_ = PVector.sub(this.end, this.start);
    if(dir_.mag() < min_grown_length)
    {
      Leaf leaf = new Leaf(this.end);
      source.leaves.add(leaf);
      this.my_leaves.add(leaf);
      return;
    }

    dir_.rotate(this.angle);
    dir_.mult(this.length_loss);
    PVector newEndA = PVector.add(this.end, dir_);
    Branch newBranchA = new Branch(this.end, newEndA);
    newBranchA.source = source;

    source.branches.add(newBranchA);
    source.growing_branches.add(newBranchA);
    this.sub_branches.add(newBranchA);

    dir_.rotate(-2 * this.angle);
    PVector newEndB = PVector.add(this.end, dir_);
    Branch newBranchB = new Branch(this.end, newEndB);
    newBranchB.source = source;

    source.branches.add(newBranchB);
    source.growing_branches.add(newBranchB);
    this.sub_branches.add(newBranchB);
  }

  ArrayList<Branch> get_all_sub_branches()
  {
    ArrayList<Branch> retval = new ArrayList<Branch>();
    for(Branch branch : this.sub_branches)
    {
      for(Branch ret_branch : branch.get_all_sub_branches())
      {
        retval.add(ret_branch);
      }
      retval.add(branch);
    }
    return retval;
  }

  void setAcceleration()
  {
    float x_offset_acc = (this.default_end.x - this.end.x) * this.friction * this.default_len;
    float y_offset_acc = (this.default_end.y - this.end.y) * this.friction * this.default_len;

    this.AccX = wind_acc_x - this.SpeedX * (this.friction + airFriction) * this.default_len + x_offset_acc;
    this.AccY = wind_acc_y + gravity - this.SpeedY * (this.friction + airFriction) * this.default_len + y_offset_acc;
    if(mousePressed)
    {
      float x_offset = this.end.x - mouseX;
      float y_offset = this.end.y - mouseY;

      this.AccX += x_offset * mouse_acc_x;
      this.AccY += y_offset * mouse_acc_y;
    }
  }

  void applySpeed()
  {
    this.SpeedX += this.AccX * dt / this.default_len;
    this.SpeedY += this.AccY * dt / this.default_len;

    if(abs(this.SpeedX) > 10 || abs(this.SpeedY) > 10)
    {
      for(int i = this.my_leaves.size() - 1; i >= 0; i--)
      {
        Leaf leaf = this.my_leaves.get(i);
        this.my_leaves.remove(leaf);
        this.source.leaves.remove(leaf);
        leaf.fall();
      }
    }

    PVector b_old_vector = PVector.sub(this.end, this.start);
    PVector b_speed = new PVector(this.SpeedX * dt, this.SpeedY * dt);
    PVector b_end_speed = PVector.add(b_speed, this.end);

    PVector b_false_vector = PVector.sub(b_end_speed, this.start);
    b_false_vector.mult(this.default_len / b_false_vector.mag());

    this.end.add(PVector.sub(b_false_vector, b_old_vector));
  }

  void setColor()
  {
    this.Color = color(42.0, sun.Light * 0.5, min(100.0, sun.Light + moon.Light) * 0.5);
  }

  void drawSelf()
  {
    stroke(this.Color);
    line(start.x, start.y, end.x, end.y);
  }
}

class Drop extends PhysicsObj
{
  color Color = color(210.0, 100.0, 100.0, 50.0);

  float z;

  int unique_number = 0;

  float alpha;
  float Length = 0;

  Drop(PVector pos)
  {
    super(pos);
    this.reset();
    processees.add(this);
    renderees.add(this);
    this.unique_number = unique_raindrop_number++;
  }

  void reset()
  {
    this.z = random(0.0, 20.0);

    this.pos.x = random(-width / 2, 3 * width / 2);
    this.pos.y = random(-100, -10000);

    this.Length = map(this.z, 0.0, 20.0, 4.0, 16.0);
    this.alpha = map(this.z, 0.0, 20.0, 100.0, 255.0);

    float satur = map(this.z + sun.Light * 0.5, 0.0, 70.0, 5.0, 100.0);
    float bright = map(this.z + min(100.0, sun.Light + moon.Light) * 0.5, 0.0, 70.0, 5.0, 100.0);
    this.Color = color(210.0, satur, bright, this.alpha);

    this.SpeedX = 0;
    this.SpeedY = this.z;
  }

  void setAcceleration()
  {
    this.AccX = -this.SpeedX * airFriction * this.Length + wind_acc_x;
    this.AccY = gravity - this.SpeedY * airFriction * this.Length + wind_acc_y;

    if(mousePressed)
    {
      float x_offset = this.pos.x - mouseX;
      float y_offset = this.pos.y - mouseY;

      this.AccX += x_offset * mouse_acc_x;
      this.AccY += y_offset * mouse_acc_y;
    }
  }

  void applySpeed()
  {
    this.SpeedX += this.AccX * dt / this.Length;
    this.SpeedY += this.AccY * dt / this.Length;

    this.pos.x += this.SpeedX * dt;
    this.pos.y += this.SpeedY * dt;
  }

  void stayInCanvas()
  {
    if(this.pos.y > height)
    {
      this.reset();
    }

    if(this.pos.x > 3 * width / 2 || this.pos.x < -width / 2)
    {
      this.reset();
    }
  }

  void drawSelf()
  {
    if(this.unique_number <= random_drops)
    {
      stroke(this.Color, alpha);
      line(this.pos.x, this.pos.y, this.pos.x + this.SpeedX, this.pos.y + this.Length + this.SpeedY);
    }
  }
}

class Leaf extends PhysicsObj
{ 
  boolean falling = false;

  int Size = 8;

  Leaf(PVector pos)
  {
    super(pos);
    renderees.add(this);
  }

  void setAcceleration()
  {
    if(falling)
    {
      this.AccX = -this.SpeedX * airFriction * PI * pow(this.Size / 2, 2) + wind_acc_x;
      this.AccY = gravity - this.SpeedY * airFriction * PI * pow(this.Size / 2, 2) + wind_acc_y;

      if(mousePressed)
      {
        float x_offset = this.pos.x - mouseX;
        float y_offset = this.pos.y - mouseY;

        this.AccX += x_offset * mouse_acc_x;
        this.AccY += y_offset * mouse_acc_y;
      }
    }
  }

  void applySpeed()
  {
    this.SpeedX += this.AccX * dt / (PI * pow(this.Size / 2, 2));
    this.SpeedY += this.AccY * dt / (PI * pow(this.Size / 2, 2));

    this.pos.x += this.SpeedX * dt;
    this.pos.y += this.SpeedY * dt;
  }

  void stayInCanvas()
  {
    if((this.pos.y + this.Size / 2) > height)
    {
      this.SpeedX -= this.SpeedX * groundFriction * dt; // We both multiply by (PI * pow(this.Size / 2, 2)), as that is our contact area, and divide by it, as it's our "mass". Weird stuff.
      this.SpeedY -= this.SpeedY * groundFriction * dt;
      this.SpeedY *= -1;
      this.pos.y = height - this.Size / 2;
    }
    else if((this.pos.y - this.Size / 2) < -this.Size)
    {
      this.SpeedY = 0.0;
      this.pos.y = -this.Size / 2;
    }
    if((this.pos.x - this.Size / 2) < 0.0 || (this.pos.x + this.Size / 2) > width)
    {
      processees.remove(this);
      renderees.remove(this);
    }
  }

  void setColor()
  {
    this.Color = color(140.0, sun.Light, min(100.0, sun.Light + moon.Light), 50.0);
  }

  void drawSelf()
  {
    stroke(this.Color);
    fill(this.Color);
    ellipse(this.pos.x, this.pos.y, this.Size, this.Size);

    if(!falling && dist(this.pos.x, this.pos.y, mouseX, mouseY) < (this.Size / 2) + 2)
    {
      this.fall();
    }
  }

  void fall()
  {
    PVector old_pos = this.pos;
    this.pos = new PVector();
    this.pos.set(old_pos);
    this.falling = true;
    processees.add(this);
  }
}

class Moon
{
  float X = width / 2;
  float Y = height * 1.5;

  float Light = 0.0;
  float Size = 100.0;

  float hue = 190.0;
  float satur = 10.0;
  float bright = 80.0;

  float SpeedX = 0.0;
  float SpeedY = 0.0;

  float DefaultAccY = -0.00025;

  float AccX = 0.0;
  float AccY = this.DefaultAccY;

  void drawSelf()
  {
    if(mousePressed)
    {
      if(dist(this.X, this.Y, pmouseX, pmouseY) < (this.Size / 2))
      {
        this.X = mouseX;
        this.Y = mouseY;
      }
    }
    this.SpeedX += this.AccX * dt;
    this.SpeedY += this.AccY * dt;

    this.X += this.SpeedX * dt;
    this.Y += this.SpeedY * dt;

    if(this.Y < -height * 0.5)
    {
      this.Y = -height * 0.5;
      this.SpeedY *= -1;
    }
    else if(this.Y > height * 1.5)
    {
      this.Y = height * 1.5;
      this.AccY = this.DefaultAccY;
      this.SpeedY = 0.0;
    }

    this.Size = map(this.Y, height * 1.5, -height * 0.5, 1.0, 100.0);
    this.hue = 190.0;
    this.satur = 10.0;

    float overlap = map(((this.Size + sun.Size) / 2) - dist(this.X, this.Y, sun.X, sun.Y), (this.Size + sun.Size) / 2, 0.0, 100.0, 0.0);
    if(overlap > 0.0 && (this.Y - (this.Size / 2)) < height && (this.Y + (this.Size / 2)) > 0.0)
    {
      if(overlap > this.Size / 2)
      {
        this.hue = sun.hue;
      }
      this.satur = ((this.satur + sun.satur) / 2) * overlap / 100.0;
      sun.Light = max(0.0, sun.Light - overlap);
    }

    this.Light = map(this.Y, height * 1.5, -height * 0.5, 0.0, sun.Light);

    stroke(this.hue, this.satur, this.bright);
    fill(this.hue, this.satur, this.bright);
    ellipse(this.X, this.Y, this.Size, this.Size);
  }
}

import os
destination = open("../algorithmicbotany.pde", "w")

path = "./"

source_file = "source.pde"

def parse_file (filepath):
  _file = open(path+"\\"+filepath)
  data = _file.readlines()
  for line in data:
    if line.find(") != -1:
      destination.write(line[0:line.find(")]+line[line.find("public")+7:len(line)])
      continue
    destination.write(line)
  destination.write("\n")

parse_file(source_file)

for root, dirs, files in os.walk(path):  
  for file in files:
    if (file == "source.pde"):
      continue
    parse_file(file)

destination.close()
class PhysicsObj
{
  // The current position of this very object.
  PVector pos;

  // These variables are related to how the object moves. They should be private or restricted really.
  float SpeedX = 0.0;
  float SpeedY = 0.0;

  float AccX = 0.0;
  float AccY = 0.0;

  // The very color of our object. It's placed here so we can easily dynamically change it based on lightning.
  color Color;

  // Used to flag those objects that are up for deletion.
  boolean deleting;

  PhysicsObj()
  {
  }

  PhysicsObj(PVector pos)
  {
    this.pos = pos;
  }

  // Call this function only in draw/threading processing function to process the object.
  void process()
  {
    this.setAcceleration();
    this.applySpeed();
    this.stayInCanvas();
  }

  void render()
  {
    this.setColor();
    this.drawSelf();
  }

  // This function should set the acceleration based on all the forces that this object should account for.
  void setAcceleration()
  {
    this.AccX = 0.0;
    this.AccY = 0.0;
  }

  // This function should be overwritten only when special features are added, such as falling off leaves, or such.
  void applySpeed()
  {
    this.SpeedX += this.AccX * dt;
    this.SpeedY += this.AccY * dt;

    this.pos.x += this.SpeedX * dt;
    this.pos.y += this.SpeedY * dt;
  }

  // This function should have contents of helping our object staying in canvas. If ever required.
  void stayInCanvas()
  {
  }

  // Set our color based on light, mostly.
  void setColor()
  {
  }

  // This function is called to draw the object.
  void drawSelf()
  {
  }
}

class Sun
{
  float X = width / 2;
  float Y = height * 1.5;

  float Light = 0.0;
  float Size = 100.0;

  float hue = 50.0;
  float satur = 100.0;
  float bright = 100.0;

  float SpeedX = 0.0;
  float SpeedY = 0.0;

  float DefaultAccY = -0.0005;

  float AccX = 0.0;
  float AccY = this.DefaultAccY;

  void drawSelf()
  {
    if(mousePressed)
    {
      if(dist(this.X, this.Y, pmouseX, pmouseY) < (this.Size / 2))
      {
        this.X = mouseX;
        this.Y = mouseY;
      }
    }
    this.SpeedX += this.AccX * dt;
    this.SpeedY += this.AccY * dt;

    this.X += this.SpeedX * dt;
    this.Y += this.SpeedY * dt;

    if(this.Y < -height * 0.5)
    {
      this.Y = -height * 0.5;
      this.SpeedY *= -1;
    }
    else if(this.Y > height * 1.5)
    {
      this.Y = height * 1.5;
      this.AccY = this.DefaultAccY;
      this.SpeedY = 0.0;
    }

    this.Size = map(this.Y, height * 1.5, -height * 0.5, 1.0, 100.0);
    this.Light = map(this.Y, height * 1.5, -height * 0.5, 0.0, 100.0);
    this.hue = map(this.Y, height * 1.5, height * 0.25, 30.0, 50.0);

    stroke(this.hue, this.satur, this.bright);
    fill(this.hue, this.satur, this.bright);
    ellipse(this.X, this.Y, this.Size, this.Size);
  }
}

class Tree
{
  ArrayList<Branch> branches = new ArrayList<Branch>();
  ArrayList<Leaf> leaves = new ArrayList<Leaf>();

  ArrayList<Branch> growing_branches = new ArrayList<Branch>();

  Branch root;

  int grown_times = 0;

  Tree(float x, float y)
  {
    this.root = new Branch(new PVector(x, y), new PVector(x, y - map(hs1.getPos(), 1.0, width, 1.0, 200.0)));
    this.root.source = this;
    this.branches.add(root);
    this.growing_branches.add(root);
  }

  void Del()
  {
    for(Branch branch : branches)
    {
      processees.remove(branch);
      renderees.remove(branch);
    }
    for(Leaf leaf : leaves)
    {
      renderees.remove(leaf);
    }
  }

  void grow()
  {
    if(grown_times > max_grown_times)
    {
      return;
    }
    for(int i = this.growing_branches.size() - 1; i >= 0; i--)
    {
      Branch branch = this.growing_branches.get(i);
      branch.grow(this);
      this.growing_branches.remove(branch);
    }
    grown_times++;
  }
}

