{$uniqid = uniqid()}
{$dict->weeks_events}

<table cellpadding="0" cellspacing="0" border="0" width="100%" class="cerb-calendar-headings">
	{$day_labels = [Sun,Mon,Tue,Wed,Thu,Fri,Sat]}
	
	<tr>
		<td colspan="7">
			<h3>{$dict->scope.calendar_date|devblocks_date:'F Y'}</h3>
		</td>
	</tr>
	
	<tr>
	{foreach from=$day_labels item=day}
		<th>{$day}</th>
	{/foreach}
	</tr>
	
</table>

<table id="calendar{$uniqid}" cellpadding="0" cellspacing="0" border="0" width="100%" class="cerb-calendar">

{foreach from=$dict->weeks item=days key=week_idx}
	<tr>
	{foreach from=$days item=day key=day_ts}
		<td cerb-calendar-ts="{$day_ts}" class="{if $day.is_padding}cerb-calendar-padding{/if} {if count($day.events) > 0}cerb-calendar-day-with-events{/if} {if $dict->scope.today == $day_ts}today{/if}">
			<div>{$day.dom}</div>
		</td>
	{/foreach}
	</tr>
{/foreach}

</table>

<div class="cerb-calendar-events ui-content"></div>

<script type="text/javascript">
$(document).on('pageinit', function() {
	var $calendar = $('#calendar{$uniqid}');
	
	$calendar
		.each(function() {
			var days = {
				{foreach from=$dict->weeks item=days key=week_idx name=weeks}
				{foreach from=$days item=day key=day_ts name=days}
				'{$day_ts}': {
					'ts': {$day_ts},
					'dom': {$day.dom},
					'dow': {$day.dow},
					'is_padding': {if $day.is_padding}true{else}false{/if},
					'events': [
						{foreach from=$day.events item=event name=events}
						{
							'label': '{$event.label}',
							'ts': {$event.ts},
							'ts_end': {$event.ts_end},
							'is_available': {if $event.is_available}true{else}false{/if},
							'color': '{$event.color}',
							'context': '{$event.event__context}',
							'context_id': '{$event.event_id}'
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
		
		if(events.length > 0)
			$td.addClass('selected');
		
		var $output = $table.siblings('div.cerb-calendar-events').html('');

		$output.append($('<h3 style="margin-left:-10px;">' + new Date(day.ts * 1000).toDateString() + '</h3>'));
		var $choicelist = $('<div data-role="choicelist"><ul data-role="listview" data-inset="false" data-theme="a"></ul></div>');
		var $ul = $choicelist.find('ul');
		
		if(events.length == 0) {
			$ul.append($('<li>There are no events on this date.</li>'));
			
		} else {
			for(idx in events) {
				var $li = $('<li></li>');
				
				// [TODO] Proper URL rewriting
				if(events[idx].context != '') {
					var $a = $('<a href="/m/profile/' + events[idx].context + '/' + events[idx].context_id + '"></a>');
					$a.append($('<h3>' + events[idx].label + '</h3>'));
					
					var ts_start = events[idx].ts * 1000;
					var ts_end = events[idx].ts_end * 1000;
		
					var $desc = $('<div class="ui-li-desc"></div>');
				
					$desc.append($('<span>' + moment(ts_start).format('h:mma') + '</span>'));
					
					if(ts_end == ts_start) {
						// Do nothing if start/stop at the same moment
					} else {
						$desc.append($('<span> - ' + moment(ts_end).format('h:mma') + '</span>'));
					}
					
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
	
	if(undefined !== localStorage.profile_calendar_day_ts) {
		try {
			$calendar.find('td[cerb-calendar-ts="' + localStorage.profile_calendar_day_ts + '"]').click();
		} catch(e) {
		}
	}
});
</script>