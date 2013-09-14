{$uniqid = uniqid()}

{$message_timeline_ids = array_keys($dict->ticket__messages)}
{$page_total = $dict->ticket_num_messages}
{$message_index = array_search($dict->id, $message_timeline_ids)}
{$page_current = $message_index + 1}

{capture name=message_paging}
<div style="text-align:center;">
<form action="javascript:;" method="post" class="cerb-profile-ticket-message-form{$uniqid}" onsubmit="return false;">
<input type="hidden" name="c" value="m">
<input type="hidden" name="a" value="profileTicketGetMessage">
<input type="hidden" name="ticket_id" value="{$dict->ticket_id}">

	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td align="left" width="15%">
				{if $page_current > 1}
				<button type="button" class="prev" data-role="button" data-inline="true" data-icon="arrow-l" data-iconpos="notext"></button>
				{/if}
			</td>
			
			<td align="center" width="70%">
				Message <b>{$page_current}</b> of <b>{$page_total}</b>
			</td>
			
			<td align="right" width="15%">
				{if $page_current < $page_total}
				<button type="button" class="next" data-role="button" data-inline="true" data-icon="arrow-r" data-iconpos="notext"></button>
				{/if}
			</td>
		</tr>
	</table>
	
</form>
</div>
{/capture}

<div class="cerb-message-paging-bottom">
{$smarty.capture.message_paging nofilter}
</div>

{$dict->created|devblocks_prettytime}, <b>{$dict->sender__label}</b> wrote:
<div class="cerb-message-contents">{$dict->content|trim|truncate:25000|escape:'htmlall'|devblocks_hyperlinks nofilter}</div>

<a href="{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Ticket::ID}&action=showReplyDialog&message_id={$dict->id}{/devblocks_url}" data-rel="dialog" data-transition="flip" data-role="button" ata-iconpos="left">Reply</a>

<script type="text/javascript">
$(function() {
	var $frm = $('form.cerb-profile-ticket-message-form{$uniqid}');
	
	$frm.find('button.prev').on('click', function() {
		$.get(
			'{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Ticket::ID}&action=getMessage&id={$message_timeline_ids.{$message_index-1}}{/devblocks_url}',
			function(html) {
				$page.find('div.cerb-profile-ticket-message').html(html).trigger('create');
			}
		);
	});
	
	$frm.find('button.next').on('click', function() {
		$.get(
			'{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Ticket::ID}&action=getMessage&id={$message_timeline_ids.{$message_index+1}}{/devblocks_url}',
			function(html) {
				$page.find('div.cerb-profile-ticket-message').html(html).trigger('create');
			}
		);
	});
});
</script>