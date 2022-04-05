
require('jsrender')($); // Load JsRender as jQuery plugin (jQuery instance as parameter)

let root = window || this;

function hashAddKeyPrefix(prefix, hash) {
  let newHash = {};
  Object.keys(hash).forEach(dataKey =>
    newHash[prefix+dataKey] = hash[dataKey]
  );
  return newHash;
}

function mergeTimeData(which_db, timeData, all_data) {
  let prefixData = hashAddKeyPrefix(which_db, timeData);
  if (which_db == 'replica') {
    let other_db = 'primary';
    let exist_one = all_data[other_db][~~timeData.timeInt];
    if (exist_one) {
      // console.log(timeData.timeInt, 'exist on', other_db, exist_one);
      prefixData2 = hashAddKeyPrefix(other_db, exist_one);
      Object.keys(prefixData2).forEach(function(key) {
        prefixData[key] = prefixData2[key];
      });
    }
  }
  return prefixData;
}

function applyDataByDB(which_db, all_data) {
  let data_index = 0;
  let that = this;
  that.db_name = which_db;
  let currDb = all_data[which_db]

  $.each(currDb, function(timeInt, timeData) {
    data_index += 1;
    timeData.Active = 'active'
    timeData.dataIndex = data_index;
    timeData.timeInt = timeInt;
    timeData.start_timef = new Date(timeData.start_timef*1000.0).format("HH:mm:ss.S");
    let prefixData = mergeTimeData(which_db, timeData, all_data);
    prefixData.timeInt = timeInt;

    let tmpl = $.templates($('#tmplEmptyTr').html());
    let htmlTr = tmpl.render(prefixData);
    let existHtmlTr = $("#tbody-data>tr[data-id='"+timeInt+"']");

    $('.table-dashboard th.active').removeClass('active')
    if (existHtmlTr.length == 1) {
      $('#tbody-data').html(htmlTr);
    } else if (existHtmlTr.length > 1) {
      console.error(timeInt, "Error html", existHtmlTr)
    } else {
      $('#tbody-data').append(htmlTr);
    }
  });
  let dataCount = Object.keys(currDb).length
  if (dataCount < 15) {
    console.log(db_name, dataCount, 'rows renderd at', Date.now()/1000.0);
  }
}

root.refreshDashboard = function() {
  if($('.table-dashboard').length > 0) {
    $.ajax({
      url: '/api/dashboard?type=all',
      data: {},
      dataType: 'json',
      success: function(data, status, res) {
        root.allDbData = data;
        // console.log('XHR success at', Date.now()/1000.0)
        $.each(data, function(which_db, db_data) {
          applyDataByDB(which_db, data);
        });
      },
      error: function(data, status, res) {
        console.error('XHR error', data);
      }
    });
  }
}

$(function(e) {
  refreshDashboard();
  root.refreshInt = setInterval('refreshDashboard()', 1000);
  // clearInterval(refreshInt);
});
