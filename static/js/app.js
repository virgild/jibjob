/* Resizer
   A helper object for changing font size.
*/
function RSResizer(target, increaser, decreaser, resetter) {
  this.target = target;
  this.increaser = increaser;
  this.decreaser = decreaser;
  this.resetter = resetter;
  this.original_size = parseInt($(this.target).css("font-size"));
  this.min_level = 1;
  this.max_level = 8;
  this.current_level = 1;
  var resizer = this;
  
  $(this.increaser).click(function(event) {
    resizer.up();
    return false;
  });
  
  $(this.decreaser).click(function(event) {
    resizer.down();
    return false;
  });
  
  $(this.resetter).click(function(event) {
    resizer.reset();
    return false;
  });
}

RSResizer.prototype.reset = function() {
  this.setLevel(1);
};

RSResizer.prototype.up = function() {
  if (this.current_level < this.max_level) {
    this.setLevel(this.current_level + 1);
  }
};

RSResizer.prototype.down = function() {
  if (this.current_level > this.min_level) {
    this.setLevel(this.current_level - 1);
  }
};

RSResizer.prototype.setLevel = function(level) {
  var modifier = (level - 1) + this.original_size;
  $(this.target).css("font-size", modifier + "px");
  this.current_level = level;
};
/* End Resizer */