
require('jsrender')($); // Load JsRender as jQuery plugin (jQuery instance as parameter)

let root = window || this;

function hashAddKeyPrefix(prefix, hash) {
  let newHash = {};
  Object.keys(hash).forEach(dataKey =>
    newHash[prefix+dataKey] = hash[dataKey]
  );
  return newHash;
}

function comparedTimeData(lastData, timeData) {
  let incrSuffix = 'Incr';
  let delaySuffix = 'Delay'
  if (!$.isEmptyObject(lastData)) {
    let primaryTotalInc = 0;
    let replicaTotalInc = 0;

    Object.keys(lastData).forEach(function(dataKey) {
      if (dataKey.endsWith('Timef')) {
        let delaySecond = (timeData[dataKey] - lastData[dataKey]).toFixed(2);
        if (delaySecond >= 0) {
          timeData[dataKey+delaySuffix] = delaySecond+'秒';
        }
      } else if (dataKey.endsWith('Count')) {
        let incCount = timeData[dataKey] - lastData[dataKey];
        if (incCount == 0) {
          timeData[dataKey+incrSuffix] = '';
        } else {
          if (incCount < 0) {
            // console.error(dataKey, 'Decr', incCount, timeData, lastData);
          } else {
            if (dataKey.startsWith('primary')) {
              primaryTotalInc += incCount
            } else {
              replicaTotalInc += incCount
            }
            // console.log(dataKey, incrSuffix, incCount);
            timeData[dataKey+incrSuffix] = ' 新增 '+incCount;
          }
        }
      }
    });

    timeData['replicaDbStatus'] = 'SyncWorking';
    if (replicaTotalInc > 0) {
      timeData['replicaTotalInc'] = ' 新增 '+replicaTotalInc;
      // console.log(lastData, 'Incr to', timeData);
    }

    if (primaryTotalInc > 0) {
      timeData['primaryTotalInc'] = ' 新增 '+primaryTotalInc;

      if (primaryTotalInc > replicaTotalInc) {
        if (replicaTotalInc == 0 && primaryTotalInc > 3) {
          timeData['replicaDbStatus'] = 'SyncStoped';
          timeData['replicaTotalInc'] = '已暂停'
        } else if (replicaTotalInc >= 0) {
          timeData['replicaDbStatus'] = 'SyncDelayed';
          // timeData['replicaTotalInc'] = ' 延迟 '+(primaryTotalInc-replicaTotalInc);
        }
      }
    }
  }
  return timeData;
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
      prefixData = comparedTimeData(lastPrefixData, prefixData);
      lastPrefixData = prefixData;
    }
  }
  return prefixData;
}

function applyDataByDB(which_db, all_data) {
  let data_index = 0;
  let that = this;
  that.db_name = which_db;
  let currDb = all_data[which_db]
  let dataCount = Object.keys(currDb).length
  if (dataCount < 15) {
    console.log(db_name, dataCount, 'rows render at', Date.now()/1000.0);
  }

  lastTimef = currDb[Object.keys(currDb)[Object.keys(currDb).length-1]].StartTimef;
  lastTimeStr = new Date(lastTimef*1000.0).format("HH:mm:ss.S");
  let tipHtml = lastTimeStr+" 刷新"+dataCount+"行";
  if (refreshBtn.text().includes(lastTimeStr)) {
    refreshBtn.html(tipHtml).removeClass('btn-success');
  } else {
    refreshBtn.html(tipHtml).addClass('btn-success');
  }

  $.each(currDb, function(timeInt, timeData) {
    data_index += 1;
    timeData.Active = 'active'
    timeData.dataIndex = data_index;
    timeData.timeInt = timeInt;
    timeData.StartTimeStr = new Date(timeData.StartTimef*1000.0).format("HH:mm:ss.S");
    // console.log(db_name, 'timeData', data_index, 'render at', timeData.StartTimeStr);
    let prefixData = mergeTimeData(which_db, timeData, all_data);
    prefixData.timeInt = timeInt;

    $('.table-dashboard th.active').removeClass('active')
    let tmpl = $.templates($('#tmplEmptyTr').html());
    let htmlTr = tmpl.render(prefixData);
    let existHtmlTr = $("#tbody-data>tr[data-id='"+timeInt+"']");
    if (existHtmlTr.length == 1) {
      $('#tbody-data').html(htmlTr);
    } else if (existHtmlTr.length > 1) {
      console.error(timeInt, "Error html", existHtmlTr)
    } else {
      $('#tbody-data').append(htmlTr);
    }
  });
}

root.refreshDashboard = function() {
  if($('.table-dashboard').length > 0) {
    refreshIndex += 1;
    refreshBtn.removeClass('btn-success');
    // console.log(refreshIndex+'th XHR begin at', (new Date()).format("HH:mm:ss.S"))
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
  root.lastPrefixData = {};
  root.refreshIndex = 0
  root.refreshBtn = $('button.toogleRefresh');
  refreshBtn.on('click', function(e) {
    if (root.refreshInt) {
      refreshBtn.removeClass('btn-success')
      clearInterval(root.refreshInt);
      root.refreshInt = undefined;
    } else {
      refreshBtn.addClass('btn-success')
      root.refreshInt = setInterval('refreshDashboard()', 1000);
    }
  });
  refreshDashboard()
  // refreshBtn.click();
});
