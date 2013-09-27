{$monthyear = $visit->get("calendar_{$dict->id}_monthyear")}
{if is_array($monthyear)}
{$month = $monthyear.month}
{$year = $monthyear.year}
{/if}

{$calendar = DAO_Calendar::get($dict->id)}
{$calendar_properties = DevblocksCalendarHelper::getCalendar($month, $year)}
{$calendar_events = $calendar->getEvents($calendar_properties.date_range_from, $calendar_properties.date_range_to)}
{$availability = $calendar->computeAvailability($calendar_properties.date_range_from, $calendar_properties.date_range_to, $calendar_events)}
{$availability->occludeCalendarEvents($calendar_events)}

{$uniqid = uniqid()}

<div style="text-align:center;font-size:0.9em;">
<form action="javascript:;" method="post" id="cerb-form-calendar-paging{$uniqid}" onsubmit="return false;">
<input type="hidden" name="c" value="m">
<input type="hidden" name="a" value="handleProfileBlockRequest">
<input type="hidden" name="extension" value="{MobileProfile_Calendar::ID}">
<input type="hidden" name="action" value="calendarPage">
<input type="hidden" name="id" value="{$dict->id}">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td width="1%" nowrap="nowrap">
				<button type="button" class="prev" data-role="button" data-inline="true" data-icon="arrow-l" data-iconpos="notext"></button>
			</td>
			<td width="97%">
				<b style="font-size:125%;">{$calendar_properties.calendar_date|devblocks_date:'F Y'}</b>
			</td>
			<td width="1%" nowrap="nowrap">
				<button type="button" class="next" data-role="button" data-inline="true" data-icon="arrow-r" data-iconpos="notext"></button>
			</td>
			<td width="1%" nowrap="nowrap">
				<button type="button" class="today" data-role="button" data-inline="true" data-icon="false" data-mini="true">today</button>
			</td>
		</tr>
	</table>
</form>
</div>

<table cellpadding="0" cellspacing="0" border="0" width="100%" class="cerb-calendar-headings">
	{$day_labels = [Sun,Mon,Tue,Wed,Thu,Fri,Sat]}
	
	<tr>
	{foreach from=$day_labels item=day}
		<th>{$day}</th>
	{/foreach}
	</tr>
	
</table>

<table id="calendar{$uniqid}" cellpadding="0" cellspacing="0" border="0" width="100%" class="cerb-calendar">

{foreach from=$calendar_properties.calendar_weeks item=days key=week_idx}
	<tr>
	{foreach from=$days item=day key=day_ts}
		<td cerb-calendar-ts="{$day_ts}" class="{if $day.is_padding}cerb-calendar-padding{/if} {if count($calendar_events.$day_ts) > 0}cerb-calendar-day-with-events{/if} {if $calendar_properties.today == $day_ts}today{/if}">
			<div>{$day.dom}</div>
		</td>
	{/foreach}
	</tr>
{/foreach}

</table>

<div class="cerb-calendar-events ui-content"></div>

{if $calendar->isWriteableByActor($active_worker) && empty($calendar->params.manual_disabled)}
<a href="{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Calendar::ID}&action=showAddEventDialog&calendar_id={$dict->id}{/devblocks_url}" data-rel="dialog" data-transition="flip" data-role="button" data-theme="c" data-icon="false">Add calendar event</a>
{/if}

<script type="text/javascript">
var $calendar = $('#calendar{$uniqid}');
var $calendar_container = $calendar.closest('div.cerb-calendar');

$calendar
	.each(function() {
		var days = {
			{foreach from=$calendar_properties.calendar_weeks item=days key=week_idx name=weeks}
			{foreach from=$days item=day key=day_ts name=days}
			'{$day_ts}': {
				'ts': {$day_ts},
				'dom': {$day.dom},
				'dow': {$day.dow},
				'is_padding': {if $day.is_padding}true{else}false{/if},
				'events': [
					{foreach from=$calendar_events.$day_ts item=event name=events}
					{
						'label': '{$event.label}',
						'ts': {$event.ts},
						'ts_end': {$event.ts_end},
						'is_available': {if $event.is_available}true{else}false{/if},
						'color': '{$event.color}',
						'context': '{$event.context}',
						'context_id': '{$event.context_id}'
					}{if !$smarty.foreach.events.last},{/if}
					{/foreach}
				]
			},
			{/foreach}
			{/foreach}
		};
		
		$(this).jqmData('days', days);
		
	})
	.find('td')
		.off('click').on('click', function() {
			var $this = $(this);
			var $calendar = $this.closest('table.cerb-calendar');
			var days = $calendar.jqmData('days');
			var day_ts = $this.attr('cerb-calendar-ts');
			
			var event = $.Event('devblocks-calendar-click', {
				'day': days[day_ts]
			});
			
			$calendar.trigger(event);
		})
	;
	
$calendar.off('devblocks-calendar-click').on('devblocks-calendar-click', function(e) {
	var $table = $(this);
	
	if(e.day == undefined)
		return;
	
	localStorage.profile_calendar_day_ts = e.day.ts;
	
	var $td = $table.find('td[cerb-calendar-ts=' + e.day.ts + ']');
	var day = e.day;
	var events = day.events;
	
	$table.find('td').removeClass('selected');
	
	$td.addClass('selected');
	
	var $output = $table.siblings('div.cerb-calendar-events').html('');

	$output.append($('<h3 style="margin-left:-10px;">' + moment(day.ts * 1000).format('ddd, MMM DD YYYY') + '</h3>'));
	var $choicelist = $('<div data-role="choicelist"><ul data-role="listview" data-inset="false" data-theme="c"></ul></div>');
	var $ul = $choicelist.find('ul');
	
	if(events.length == 0) {
		$ul.append($('<li>There are no events on this date.</li>'));
		
	} else {
		for(idx in events) {
			var $li = $('<li></li>');
			
			if(events[idx].context != '') {
				var $a = $('<a href="{devblocks_url}c=m&a=profile{/devblocks_url}/' + events[idx].context + '/' + events[idx].context_id + '"></a>');
				$a.append($('<h3>' + events[idx].label + '</h3>'));
				
				var ts_start = events[idx].ts * 1000;
				var ts_end = events[idx].ts_end * 1000;
				var is_available = events[idx].is_available;
	
				var $desc = $('<div class="ui-li-desc"></div>');
			
				$desc.append($('<span>' + moment(ts_start).format('h:mma') + '</span>'));
				
				if(ts_end == ts_start) {
					// Do nothing if start/stop at the same moment
				} else {
					$desc.append($('<span> - ' + moment(ts_end).format('h:mma') + '</span>'));
				}
				
				$desc.append($('<span> (' + (is_available ? 'available' : 'busy') + ')</span>'));
				
				$a.append($desc)
				$li.append($a);
				
			} else {
				$li.append($('events[idx].label'));
			}
			
			$ul.append($li);
		}
	}
	
	$output.append($choicelist);
	$output.trigger('create');
});

$(document).one('pagebeforeshow', function() {
	if(undefined !== localStorage.profile_calendar_day_ts) {
		try {
			$calendar.find('td[cerb-calendar-ts="' + localStorage.profile_calendar_day_ts + '"]').click();
		} catch(e) {
		}
	}
});

$calendar_container.one('cerb-calendar-refresh', function() {
	if(undefined !== localStorage.profile_calendar_day_ts) {
		try {
			$calendar.find('td[cerb-calendar-ts="' + localStorage.profile_calendar_day_ts + '"]').click();
		} catch(e) {
		}
	}
});

var $frm_paging = $('#cerb-form-calendar-paging{$uniqid}');

$frm_paging.find('button.prev').on('click', function() {
	var $this = $(this);
	var $frm_paging = $this.closest('form');
	
	$.mobile.loading('show');
	$.post(
		'{devblocks_url}ajax.php?month={$calendar_properties.prev_month}&year={$calendar_properties.prev_year}{/devblocks_url}',
		$frm_paging.serialize(),
		function(out) {
			var $calendar_container = $('#calendar{$uniqid}').closest('div.cerb-calendar');
			$calendar_container.html(out).trigger('create').trigger('cerb-calendar-refresh');
			$.mobile.loading('hide');
		}
	);
});

$frm_paging.find('button.next').on('click', function() {
	var $this = $(this);
	var $frm_paging = $this.closest('form');
	
	$.mobile.loading('show');
	$.post(
		'{devblocks_url}ajax.php?month={$calendar_properties.next_month}&year={$calendar_properties.next_year}{/devblocks_url}',
		$frm_paging.serialize(),
		function(out) {
			var $calendar_container = $('#calendar{$uniqid}').closest('div.cerb-calendar');
			$calendar_container.html(out).trigger('create').trigger('cerb-calendar-refresh');
			$.mobile.loading('hide');
		}
	);
	
});

$frm_paging.find('button.today').on('click', function() {
	var $this = $(this);
	var $frm_paging = $this.closest('form');
	
	// Check if today is on the current calendar
	{if $calendar_properties.today >= $calendar_properties.date_range_from && $calendar_properties.today <= $calendar_properties.date_range_to}
		// Today is on this calendar
		$calendar.find('td[cerb-calendar-ts="{$calendar_properties.today}"]').click();
	
	{else}
		// Today is on a different calendar
		$.mobile.loading('show');
		$.post(
			'{devblocks_url}ajax.php?month={date('m')}&year={date('Y')}{/devblocks_url}',
			$frm_paging.serialize(),
			function(out) {
				localStorage.profile_calendar_day_ts = {$calendar_properties.today};
				
				var $calendar_container = $('#calendar{$uniqid}').closest('div.cerb-calendar');
				$calendar_container.html(out).trigger('create').trigger('cerb-calendar-refresh');
				$.mobile.loading('hide');
			}
		);
	{/if}
	
});
</script>