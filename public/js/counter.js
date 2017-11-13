(function($){})(window.jQuery);
$(document).ready(function() {

  var startCounter = function() {
    $('.counter').each(function() {
      var $this = $(this),
      countTo = $this.attr('data-count');

      $({ countNum: $this.text()}).animate({
        countNum: countTo
      },

      {
        duration: 1500,
        easing:'linear',
        step: function() {
          $this.text(Math.floor(this.countNum));
        },
        complete: function() {
          $this.text(this.countNum);
          //alert('finished');
        }

      });
    });
  }
  if ($('#info-strip').length) {
    var waypoint = new Waypoint({
      element: document.getElementById('info-strip'),
      offset: '85%',
      handler: function(direction) {
        startCounter();
      }
    });
  }
});
