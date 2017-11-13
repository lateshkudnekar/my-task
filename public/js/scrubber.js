var ts_prevslide, ts_currslide;

$(document).on('mousemove mouseleave','.thumbscrubber',function(e){

  var $this = $(this);
  var width = $(this).innerWidth();

  var $slides = $('.ts-inner',this).children();
  var numslides = $slides.length;

  if(e.type == 'mousemove'){
    x = e.pageX - $(this).offset().left;
    ts_currslide = Math.floor(x / (width / numslides)) + 1;

    if(ts_currslide != ts_prevslide){
      ts_prevslide = ts_currslide;
        $('.ts-inner > .ts-currslide',this).removeClass('ts-currslide');
        $('.ts-inner > :nth-child('+ts_currslide+')',this).addClass('ts-currslide');

      $(this).css({
        backgroundImage: 'url('+ $('.ts-inner > :nth-child('+ts_currslide+')',this).attr('src') + ')'
      });
    }
    return false;
  }
  else if(e.type == 'mouseleave'){
    if(ts_currslide != 1){
      ts_currslide = 1;
      ts_prevslide = 1;
      $('.ts-inner > .ts-currslide',this).removeClass('ts-currslide');
      $('.ts-inner > :nth-child('+ts_currslide+')',this).addClass('ts-currslide');

      $(this).css({
        backgroundImage: 'url('+ $('.ts-inner > :nth-child('+ts_currslide+')',this).attr('src') + ')'
      });
    }
    return false;
  }
});
