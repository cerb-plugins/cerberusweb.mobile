{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right">
	<div data-role="header" data-theme="b">
		<h1>Reply</h1>
	</div>
	
	<div data-role="content">
		<form id="frm{$uniqid}" method="post">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="handleProfileBlockRequest">
		<input type="hidden" name="extension" value="{MobileProfile_Ticket::ID}">
		<input type="hidden" name="action" value="saveReplyDialog">
		<input type="hidden" name="reply_to_message_id" value="{$dict->id}">

		<div data-role="fieldcontain">
			<label> To:</label>
			{foreach from=$dict->ticket_requesters item=req name=reqs}
			{$req.email}{if !$smarty.foreach.reqs.last}, {/if}
			{/foreach}
		</div>
		
		<div data-role="fieldcontain">
			<label for="frm-cerb-reply-content"> Message:</label>
{$group = DAO_Group::get($dict->ticket_group_id)} 
<textarea name="content" id="frm-cerb-reply-content">On {$dict->created|devblocks_date:'D, d M Y'}, {$dict->sender__label} wrote:
{$dict->content|devblocks_email_quotes_cull|indent:1:'> '}


{$group->getReplySignature($dict->ticket_bucket_id, $active_worker)}
</textarea>
		</div>
	
		<div data-role="fieldcontain">
			<label for="frm-cerb-reply-status"> Status:</label>
			 
			<select name="status" id="frm-cerb-reply-status">
				<option value="open">open</option>
				<option value="waiting" selected="selected">waiting for reply</option>
				<option value="closed">closed</option>
			</select>
		</div>
		
		<div data-role="fieldcontain" class="status-dependent status-waiting status-closed">
			<label for="frm-cerb-reply-reopen"> {'display.reply.next.resume'|devblocks_translate|capitalize}</label>
			 
			<input type="text" name="reopen_at" id="frm-cerb-reply-reopen" />
		</div>
		
		<button data-role="button" type="button" class="submit" data-theme="b">Send message</button>
	</div>
	
	<script type="text/javascript">
		var $frm = $('#frm{$uniqid}');
		
		$frm.find('select[name=status]').on('change', function(e) {
			var $frm = $(this).closest('form');
			$frm.find('div.status-dependent').hide();
			
			switch($(this).val()) {
				case 'open':
					$frm.find('div.status-dependent.status-open').show();
					break;
					
				case 'waiting':
					$frm.find('div.status-dependent.status-waiting').show();
					break;
					
				case 'closed':
					$frm.find('div.status-dependent.status-closed').show();
					break;
			}
		});
		
		$frm.find('button.submit').click(function(e) {
			$.mobile.loading('show');
			
			$.post(
				'{devblocks_url}c=m{/devblocks_url}',
				$frm.serialize(),
				function(json) {
					if(json.success && json.message_id !== undefined) {
						$.mobile.changePage(
							'{devblocks_url}c=m&a=profile&t={CerberusContexts::CONTEXT_TICKET}&id=' + json.ticket_id + '{/devblocks_url}',
							{
								transition: 'fade',
								changeHash: false,
								reloadPage: true
							}
						);
					}
				}
			);
		});
	</script>
</div>