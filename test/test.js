$(function(){
  var canvas = $("div#substrate");
  var substrate;

  module("Basic HTML Canvas", {
    setup: function(){
      canvas.empty().substrate({
        autopaint: false,
        grid_size: 32
      });
      substrate = canvas.data("substrate");
      console.log("set canvas %o with substrate %o", canvas, substrate);
    }
  });
  /*
  test("draw rectangle", function() {
    substrate.drawRectangle({
      x: 0,
      y: 10,
      width: 10,
      height: 20,
      fillColor: "#ccc"
    });
    substrate.drawRectangle({
      x: 20,
      y: 10,
      width: 10,
      height: 20,
      fillColor: "#ccc",
      strokeWidth: 1
    });
    substrate.drawRectangle({
      x: 40,
      y: 10,
      width: 10,
      height: 20,
      fillColor: "#ccc",
      strokeWidth: 2
    });
    var rect = substrate.drawRectangle({
      x: 60,
      y: 10,
      width: 10,
      height: 20,
      fillColor: "#ccc",
      strokeWidth: 3
    });
    rect.set("x", 200);
  });
  */
  test("draw image", function(){
    var img = substrate.drawImage({
      src: "dwarf.png",
      x: 1,
      y: 1
    });
    setTimeout(function(){
      img.paint();
      img.set("x", 2);
    }, 1000);
    setTimeout(function(){
      img.paint();
    }, 2000);
  });
});
