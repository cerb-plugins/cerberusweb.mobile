{$uniqid = uniqid()}

{$message_timeline_ids = array_keys($dict->ticket__messages)}
{$page_total = $dict->ticket_num_messages}
{$message_index = array_search($dict->id, $message_timeline_ids)}
{$page_current = $message_index + 1}

{capture name=message_paging}
{if $page_total > 0}
<div style="text-align:center;background-color:rgb(242,242,242);border:2px solid rgb(242,242,242);border-bottom-width:1px;border-radius:8px 8px 0px 0px;">
<form action="javascript:;" method="post" class="cerb-profile-ticket-message-form{$uniqid}" onsubmit="return false;">
<input type="hidden" name="c" value="m">
<input type="hidden" name="a" value="profileTicketGetMessage">
<input type="hidden" name="ticket_id" value="{$dict->ticket_id}">

	<table width="100%" cellpadding="0" cellspacing="0" border="0" style="min-height:32px;">
		<tr>
			<td align="left" width="15%">
				{if $page_current > 1}
				<button type="button" class="prev ui-icon-nodisc" data-role="button" data-inline="true" data-icon="arrow-l" data-iconpos="notext"></button>
				{/if}
			</td>
			
			<td align="center" width="70%" style="font-size:16px;color:#000;">
				<b>Message {$page_current} of {$page_total}</b>
			</td>
			
			<td align="right" width="15%">
				{if $page_current < $page_total}
				<button type="button" class="next ui-icon-nodisc" data-role="button" data-inline="true" data-icon="arrow-r" data-iconpos="notext"></button>
				{/if}
			</td>
		</tr>
	</table>
	
</form>
</div>
{/if}
{/capture}

<div class="cerb-message-paging-bottom">
{$smarty.capture.message_paging nofilter}
</div>

<div class="cerb-message-contents"><span style="color:rgb(75,75,75);font-style:italic;">{$dict->created|devblocks_prettytime}, <b>{$dict->sender__label}</b> wrote:</span>

{$dict->content|trim|truncate:25000|escape:'htmlall'|devblocks_hyperlinks nofilter}</div>

<a href="{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Ticket::ID}&action=showReplyDialog&message_id={$dict->id}{/devblocks_url}" data-rel="dialog" data-transition="flip" data-role="button">Reply</a>

<a href="{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Ticket::ID}&action=showRelayDialog&message_id={$dict->id}{/devblocks_url}" data-rel="dialog" data-transition="flip" data-role="button">Relay to worker email</a>

<script type="text/javascript">
$(function() {
	var $frm = $('form.cerb-profile-ticket-message-form{$uniqid}');
	
	$frm.find('button.prev').on('click', function() {
		$.mobile.loading('show');
		$.get(
			'{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Ticket::ID}&action=getMessage&id={$message_timeline_ids.{$message_index-1}}{/devblocks_url}',
			function(html) {
				$page.find('div.cerb-profile-ticket-message').html(html).trigger('create');
				$.mobile.loading('hide');
			}
		);
	});
	
	$frm.find('button.next').on('click', function() {
		$.mobile.loading('show');
		$.get(
			'{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Ticket::ID}&action=getMessage&id={$message_timeline_ids.{$message_index+1}}{/devblocks_url}',
			function(html) {
				$page.find('div.cerb-profile-ticket-message').html(html).trigger('create');
				$.mobile.loading('hide');
			}
		);
	});
});
</script>