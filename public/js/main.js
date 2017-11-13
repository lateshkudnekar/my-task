(function($){})(window.jQuery);
var s;
var pageslug = $(location).attr('pathname').substring(1);
var activateKeyboard = false;

$(document).ready(function() {

  var winW = $(window).width();
  var winH = $(window).height();

  const ONE_THIRD = 0.33333;
  const ONE_THIRD_WINW = winW * ONE_THIRD;
  var innerPadding = 200;
  if (winW < 480) {
    innerPadding = 0;
  }

  $('[data-toggle="popover"]').popover();

  $('#slide-2 .content').not(':first-child').hide();
  $('#design-container').css({
    minHeight: winH + 50
  })

  $('#content-blocks li a').on('click', function(e) {
    $('#content-blocks li a').removeClass('active');
    $(this).addClass('active');
    $('#slide-2 .content').hide();
    var id = $(this).attr('href');
    var image = $(this).attr('data-image');
    $(id).show();
    $('#design-container').addClass('animated').css({
        backgroundImage: "url(" + image + ")"
    });
    setTimeout(function() {
      $('#design-container').removeClass('animated');
    }, 1600);
    return false;
  });

  $.fn.validateContacts = function(element) {
    if($('input[name="name"]').val() && $('input[name="email"]').val() && $('input[name="phone"]').val()) {
      $.ajax({
        url: '/contact',
        type: 'POST',
        data: $("#contact-form").serialize(),
        success: function(result) {
          location.reload();
          // $('#form-message').html(result);
        },
        error: function(error) {
          console.log('error', error);
          $('#form-message').html(error);
        }
      });
    } else {
      $('#form-message').html("Please fill in the Name, Email & Phone fields");
    }
  }

  $(document).keydown(function(e) {
    if (activateKeyboard) {
      switch (e.which) {
        case 37:
          $.fn.scrollToNext('#application-items', 400, 'left');
        break;
        case 39:
          $.fn.scrollToNext('#application-items', 400, 'right');
        break;
        default: return;
      }
      e.preventDefault();
    }
  });

  $.fn.scrollToProduct = function(category, element, speed, offset) {
    $.fn.categoryFilter("#category-"+category, category);
    setTimeout(function() {
      $.fn.scrollToId(element, speed, offset);
      $.fn.highlightElement(element);
    }, 500);
  }

  $.fn.scrollToId = function(element, speed, offset) {
    var adjustOffset = ["applications-block", "products-block", "contact-block"];
    if (!speed) {
      speed = 400;
    }
    if (!offset) {
      offset = 0;
    }
    if (winW < 480 && $.inArray(element, '#'+adjustOffset)) { //Check if mobile
      offset = -10;
    }
    if (!$(element).length) {
      document.location.href = '/';
    }

    $('body').addClass('scrolling');
    setTimeout(function() {
      $('body').removeClass('scrolling');
    }, speed + 50);
    $.scrollTo(element, speed, {
      offset: {
        top: offset
      }
    });
    history.pushState('', document.title, $(this).attr('data-slug'));
    return false;
  }

  $.fn.scrollToNext = function(element, speed, direction) {
    if (!speed) {
      speed = 400;
    }
    if (!direction) {
      direction = "right"
    }

    var active = $(element).find('> ul > li.active');
    var target;
    if (!active.length) {
      target = $(element).find('> ul > li:first-child');
    } else {
      if (direction === "right") {
        target = active.next();
      } else {
        target = active.prev();
      }
    }
    if (target.length) {
      target.addClass('active');
      active.removeClass('active');
      $(element).scrollTo(target, speed, {
        axis: 'x',
        offset: {
          left: 0 - (((winW + 250) - target.width()) / 2)
        }
      });
    }
    return false;
  }

  $.fn.scrollToElement = function(container, element) {
    if (!$(element).hasClass('active')) {
      $(container).find('.active').removeClass('active');
      $(element).addClass('active');
      if (winW > 480) {
        $(container).scrollTo(element, 400, {
          offset: {
            left: 0 - ((winW - $(element).width()) / 2)
          }
        });
      } else {
        $.scrollTo(element, 400, {
          offset: {
            top: -65
          }
        });
      }
    }
    return false;
  }

  $.fn.deleteProduct = function(id) {
    var result = confirm("Want to delete?");
    $.ajax({
      url: '/products',
      type: 'DELETE',
      data: {
        id: id
      },
      success: function(result) {
        document.location.href = result;
      },
      error: function(error) {
        console.log('error', error);
      }
    });
  };

  $.fn.deleteApplication = function(id) {
    var result = confirm("Want to delete?");
    $.ajax({
      url: '/applications/' + id ,
      type: 'DELETE',
      success: function(result) {
        document.location.href = '/applications';
      },
      error: function(error) {
        console.log('error', error);
      }
    });
  };

  $.fn.showFilters = function(element) {
    $(element).hide();
    $.scrollTo('#products-block', 400, {
      offset: {
        top: 0
      },
      onAfter: function() {
        $('.filters-list').slideDown();
        $.fn.categoryFilter("#all-filter", "all");
      }
    });
  };


  $.fn.categoryFilter = function(element, id) {
    $('.filters-list .active').removeClass('active');
    $(element).addClass('active');
    var productGridWidth = $("#products-grid li").width();
    $("#products-grid").html("<i class='fa fa-spinner loading-placeholder'></i>");
    $.ajax({
      url: '/products',
      type: 'GET',
      data: {
        filter: true,
        id: id
      },
      success: function(result) {
        if (result.length) {
          $("#products-grid").html(result);
        } else {
          $('#products-grid').html('<span>No results in category</span>');
        }
        setProductGrid(productGridWidth);
        checkCartAfterLoad();
      },
      error: function(error) {
        console.log(error)
      }
    });
  };

  $.fn.highlightElement = function(element) {
    $(element).addClass('highlighted');
    setTimeout(function() {
      $(element).removeClass('highlighted');
    }, 10000);
  };

  var setProductGrid = function(width) {
    var gridWidth = width * 0.8;

    $('.product-grid-item').height(gridWidth);
    $('.product-grid-item .item').height(gridWidth - 2);
  };



  setProductGrid($('#products-grid li').width() * 0.8);


    $('#carousel-block, #carousel-block .item').height(winH + 25);

    $('.product-grid-item').on('mouseenter', function() {
      $(this).find('.carousel').carousel('cycle');
    }).on('mouseleave', function() {
      $(this).find('.carousel').carousel('pause');
    });

  if (winW > 480) {
    var applications_count = $('#applications-block .application-item').length;

    var padLeft = (winW - $('.container').width()) / 2;

    $('#application-items .application-item').width(ONE_THIRD_WINW);
    $('#application-items .inner').css({
      paddingLeft: padLeft - 15,
      paddingRight: innerPadding
    });

    $('#application-items .inner').width((applications_count * (ONE_THIRD_WINW + 30)) + (innerPadding * 2) + padLeft);
  }


  $.fn.setActive = function(element) {
    $('#products-grid .product-grid-item').not($(element).parent().parent().parent()).removeClass('active');
    $(element).parent().parent().parent().toggleClass('active');
    return false;
  }

  // $('#application-items .inner li:nth-child(1)').addClass(ja'active');

  $('#map').width(winW);

  $('#map-container').on('click', function() {
    $('#map-container').addClass('clicked');
  });

	// Initialise skrollr on non-touch devices
	if(!(/Android|iPhone|iPod|iPad|BlackBerry|Windows Phone/i).test(navigator.userAgent || navigator.vendor || window.opera)){
		s = skrollr.init();
	}

  if ($('#application-items').length) {
    var waypoint = new Waypoint({
      element: document.getElementById('application-items'),
      offset: '50%',
      handler: function(direction) {
        if (!$('#application-items li.active').length) {
          $('#application-items').find('li:first-child').addClass('active');
        }
      }
    });
  }

  var previousScroll = 0;
  if (winW > 768) {

    $(window).scroll(function () {
        var currentScroll = $(this).scrollTop();

        if (currentScroll < 200) {
          $('#main-nav').css({
            opacity: 1 - (currentScroll / 100)
          }).removeClass('scrolled').removeClass('show');
        }
        if (currentScroll > 200) {
            if (currentScroll > previousScroll) {
               $('#main-nav').addClass('scrolled').removeClass('show').css('opacity', 0);
            }
          if (currentScroll > winH) {
              if (currentScroll < previousScroll) {
                 $('#main-nav').addClass('show');
              }
            }
          }
        previousScroll = currentScroll;
    });
  }


  $.fn.saveCategory = function(element) {
    $.ajax({
      url: '/categories',
      type: 'POST',
      data: {
        category_title:$("#newCategory").val(),
      },
      success: function(result) {
        $("#newCategory").val('')
        $("#category-list").append(result);
      },
      error: function(error) {
        console.log('error', error);
      }
    });

  },
  $.fn.deleteCategory = function(id) {
    $.ajax({
      url: '/categories' ,
      type: 'DELETE',
      data: {
        id: id
      },
      success: function(result) {
        $("#category-item-"+id).remove();
      },
      error: function(error) {
        console.log('error', error);
      }
    });
  },

  $.fn.editCategory = function(id) {
    $.ajax({
      url: '/categories' ,
      type: 'PUT',
      data: {
        id: id,
        title:$("#editCategorytitle-"+id).val()
      },
      success: function(result) {
        $("#category-title-"+id).html(result);
        $("#edit-modal-"+id).modal('hide');
      },
      error: function(error) {
        console.log('error', error);
      }
    });
  },
  $.fn.changeCategoryPriority = function(id, direction) {
    $.ajax({
      url: '/categories' ,
      type: 'PUT',
      data: {
        id: id,
        direction: direction
      },
      success: function(result) {
        // location.reload();
        $('#categories').html(result);
      },
      error: function(error) {
        console.log('error', error);
      }
    });
  },

 $.fn.showedit = function(id) {
   $(id).modal('show');
 };

 $.fn.uploadImage = function() {
   $.ajax({
     url: '/changewelcomeimage' ,
     type: 'POST',
     enctype: 'multipart/form-data',
     processData: false,
     contentType: false,
     cache: false,
     data: new FormData($("#image_upload")[0]),
     success: function(result) {
       $("#edit-welcome").modal('hide')
       location.reload();
     },
     error: function(error) {
       console.log('error', error);
     }
   });
 };

 $.fn.showModal = function(modal, container, title) {
   $("#modal-title").text('Edit '+title);
   $("#edit-container").text($.trim($("#"+container).text()));
   $("#field").val(container);
   $(modal).modal('show');
 };

 $.fn.saveContent = function() {
   $.ajax({
     url: '/changecmscontent' ,
     type: 'POST',
     data: {
       field: $("#field").val(),
       content: $("#edit-container").val()
     },
     success: function(result) {
       $("#edit-content").modal('hide')
       location.reload();
     },
     error: function(error) {
       console.log('error', error);
     }
   });
  };

  $.fn.showModal = function(modal, container, title) {
    $("#modal-title").text('Edit '+title);
    $("#edit-container").text($.trim($("#"+container).text()));
    $("#field").val(container);
    $(modal).modal('show');
  };

  $.fn.saveContent = function() {
    $.ajax({
      url: '/changecmscontent' ,
      type: 'POST',
      data: {
        field: $("#field").val(),
        content: $("#edit-container").val()
      },
     success: function(result) {
      $("#edit-content").modal('hide')
        location.reload();
      },
      error: function(error) {
        console.log('error', error);
      }
     });
   };
}( document, window, 0 ));

$(window).load(function() {
  var slugArray = ["about-us", "applications", "products", "contact-us"]; //slugs in Index

  if (s) {
    s.refresh();
  }
  $('body').addClass('animate');
  var scrollto = 0;
  if ( pageslug.length ) { // if slug present scroll to it.
    scrollto = $('.scrollablediv[data-slug="'+ slugArray[$.inArray(pageslug, slugArray)] +'"]').offset().top;
  }
  $.scrollTo(scrollto);

  $('.scrollablediv').each(function(){ // detect scroll points and change slug. e.g. http://localhost:4567/about-us
    var slug = $(this).data('slug');
    $(this).waypoint(function(direction){
      activateKeyboard = (slug === "applications") ? true : false;
      if ( !slug.length ){ // if no slug change to root i.e. http://localhost:4567
        slug =  "/";
      }
      if (!$('body').hasClass('scrolling')) {
        history.pushState('', document.title, slug);
      }
    })
  });

  if ($(window).width() < 768) {
    setTimeout(function() {
      $('.navbar-collapse').collapse();
    }, 300);
  }
});


function handleFileSelect() {
  var files = document.getElementById('file-1').files; // FileList object

  // Loop through the FileList and render image files as thumbnails.
  for (var i = 0, f; f = files[i]; i++) {
    // Only process image files.
    if (!f.type.match('image.*')) {
      continue;
    }

    var reader = new FileReader();

    // Closure to capture the file information.
    reader.onload = (function(theFile) {
      return function(e) {
        // Render thumbnail.
        var span = document.createElement('span');
        span.innerHTML = ['<input checked=true type=radio name=priority value="',escape(theFile.name),'"><img class="img" src="', e.target.result,
                          '" title="', escape(theFile.name), '"/>'].join('');
        document.getElementById('list').insertBefore(span, null);
      };
    })(f);

    // Read in the image file as a data URL.
    reader.readAsDataURL(f);
  }
}

function deleteImage(image,id) {
  $("#"+id).hide();
  $.ajax({
    url: '/images' ,
    type: 'DELETE',
    data: {
      image: image,
    },
    success: function(result) {
    console.log('successfully Deleted')
    },
    error: function(error) {
      console.log('error', error);
    }
  });
}

function setPriority(image,product) {
  $.ajax({
    url: '/images' ,
    type: 'PUT',
    data: {
      image: image,
      product:product
    },
    success: function(result) {
    console.log('successfully esdited')
    },
    error: function(error) {
      console.log('error', error);
    }
  });
}

function showPreview(obj) {
  $('#filepreview').attr('src', window.URL.createObjectURL(obj.files[0]));
  $("#filepreview").show();
}
