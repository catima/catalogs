$(document).ready(function() {
  $("a#titreDetailLabel").click(function() {
    if($(this).attr('class') === 'inactive') {
      $(this).attr('class', 'active');
      $('#titreDetailTradLabel').attr('class', 'inactive');
      $('#titreDetailTrad').css('display', 'none');
      $('#titreDetail').css('display', 'inline');
    }
  });

  $("a#titreDetailTradLabel").click(function() {
    if ($(this).attr('class') === 'inactive') {
      $(this).attr('class', 'active');
      $('#titreDetailLabel').attr('class', 'inactive');
      $('#titreDetail').css('display', 'none');
      $('#titreDetailTrad').css('display', 'inline');
    }
  });
  
  $("a#caracteristiquesLabel").click(function(e) {
    e.preventDefault()
    d = $('#caracteristiques').css('display');
    if (d == 'none') {
      $('#arrowCaracteristiques').attr('src', '/assets/arrow-collapse.gif');
    } else {
      $('#arrowCaracteristiques').attr('src', '/assets/arrow-expand.gif');
    }
    $('#caracteristiques').animate({height: 'toggle'});
  });

    $("a#remarquesLabel").click(function() {
        d = $('#remarques').css('display');
        if (d == 'none') {
            $('#arrowRemarques').attr('src', '/assets/arrow-collapse.gif');
        } else {
            $('#arrowRemarques').attr('src', '/assets/arrow-expand.gif');
        }
        $('#remarques').animate({height: 'toggle'});
    });

    $("a#texteImageLabel").click(function() {
        d = $('#texteImage').css('display');
        if (d == 'none') {
            $('#arrowtexteImage').attr('src', '/assets/arrow-collapse.gif');
        } else {
            $('#arrowtexteImage').attr('src', '/assets/arrow-expand.gif');
        }
        $('#texteImage').animate({height: 'toggle'});
    });

    $("#sel_texte_associe").change(function() {
        var path = this.value;
        $('#inlinePdfFrame').attr('src', path);
        $('#pdfLink a').each(function() {
            $(this).attr('href', path);
        });
    });

    $('.ril-toolbar').livequery(function() {
        var content = $('#imageLegendEtablissment').length ? '© ' + $('#imageLegendEtablissment').text() + '. ' : '';
        content += $('#imageLegendDroits').length ? $('#imageLegendDroits').text() : '';
        var html = content.length ? '<div class=\"ril-caption ril__caption\"><div class=\"ril-caption-content ril__captionContent\">' + content + '</div></div>' : '';
        $(this).after(html);
    });

    replaceLineBreakBy($("#caracteristiquesGenerales"), ', ');
    replaceLineBreakBy($("#ouvrageSource"), ', ');
    replaceLineBreakBy($("#etablissementImage"), ', ');
    replaceLineBreakBy($("#chercheur"), ', ');
    replaceLineBreakBy($("#enLigne"), ', ');
    replaceLineBreakBy($("#etablissementCorpus"), ' - ');
    replaceLineBreakBy($("#caracteristiquesEmplacement"), ' - ');
});

function replaceLineBreakBy(selector, replaceBy) {
    if (selector.html() == null) { return false; }
    if (selector.html().trim()) {
        var str = selector.html().trim().replace(/[\t\n]+/g, replaceBy);
        selector.html(str);
    }
}

/*! jquery.livequery - v1.3.6 - 2016-12-09
 * Copyright (c)
 *  (c) 2010, Brandon Aaron (http://brandonaaron.net)
 *  (c) 2012 - 2016, Alexander Zaytsev (https://alexzaytsev.me)
 * Dual licensed under the MIT (MIT_LICENSE.txt)
 * and GPL Version 2 (GPL_LICENSE.txt) licenses.
 */
!function(a){"function"==typeof define&&define.amd?define(["jquery"],a):a("object"==typeof exports?require("jquery"):jQuery)}(function(a,b){function c(a,b,c,d){return!(a.selector!=b.selector||a.context!=b.context||c&&c.$lqguid!=b.fn.$lqguid||d&&d.$lqguid!=b.fn2.$lqguid)}a.extend(a.fn,{livequery:function(b,e){var f,g=this;return a.each(d.queries,function(a,d){if(c(g,d,b,e))return(f=d)&&!1}),f=f||new d(g.selector,g.context,b,e),f.stopped=!1,f.run(),g},expire:function(b,e){var f=this;return a.each(d.queries,function(a,g){c(f,g,b,e)&&!f.stopped&&d.stop(g.id)}),f}});var d=a.livequery=function(b,c,e,f){var g=this;return g.selector=b,g.context=c,g.fn=e,g.fn2=f,g.elements=a([]),g.stopped=!1,g.id=d.queries.push(g)-1,e.$lqguid=e.$lqguid||d.guid++,f&&(f.$lqguid=f.$lqguid||d.guid++),g};d.prototype={stop:function(){var b=this;b.stopped||(b.fn2&&b.elements.each(b.fn2),b.elements=a([]),b.stopped=!0)},run:function(){var b=this;if(!b.stopped){var c=b.elements,d=a(b.selector,b.context),e=d.not(c),f=c.not(d);b.elements=d,e.each(b.fn),b.fn2&&f.each(b.fn2)}}},a.extend(d,{guid:0,queries:[],queue:[],running:!1,timeout:null,registered:[],checkQueue:function(){if(d.running&&d.queue.length)for(var a=d.queue.length;a--;)d.queries[d.queue.shift()].run()},pause:function(){d.running=!1},play:function(){d.running=!0,d.run()},registerPlugin:function(){a.each(arguments,function(b,c){if(a.fn[c]&&!(a.inArray(c,d.registered)>0)){var e=a.fn[c];a.fn[c]=function(){var a=e.apply(this,arguments);return d.run(),a},d.registered.push(c)}})},run:function(c){c!==b?a.inArray(c,d.queue)<0&&d.queue.push(c):a.each(d.queries,function(b){a.inArray(b,d.queue)<0&&d.queue.push(b)}),d.timeout&&clearTimeout(d.timeout),d.timeout=setTimeout(d.checkQueue,20)},stop:function(c){c!==b?d.queries[c].stop():a.each(d.queries,d.prototype.stop)}}),d.registerPlugin("append","prepend","after","before","wrap","attr","removeAttr","addClass","removeClass","toggleClass","empty","remove","html","prop","removeProp"),a(function(){d.play()})});