{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right">
	<div data-role="header" data-theme="a">
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
			<label>Status:</label>
			 
			<div style="padding:5px;">
				<select name="status" id="frm-cerb-reply-status">
					<option value="open">open</option>
					<option value="waiting" selected="selected">waiting for reply</option>
					<option value="closed">closed</option>
				</select>
			</div>
		</div>
		
		<div data-role="fieldcontain" class="status-dependent status-waiting status-closed">
			<label> {'display.reply.next.resume'|devblocks_translate|capitalize}</label>
			 
			<div style="padding:5px;">
				<input type="text" name="reopen_at" id="frm-cerb-reply-reopen" />
			</div>
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

		$frm.find('textarea').keyup(function(e) {
			if(e.which != 13)
				return;

			var $this = $(this);
			var pos = $this.caret('pos');
			
			// Check for possible hash commands
			
			// #dq - Delete quoted lines starting at the cursor
			if($this.val().substr(pos - 4, 4) == "#dq\n") {
				e.preventDefault();
				
				var lines = $this.val().split("\n");
				var txt = [];
				var is_removing = false;
				
				for(idx in lines) {
					var line = $.trim(lines[idx]);
					
					if(line == "#dq") {
						is_removing = true;
						continue;
					}
					
					if(is_removing && !line.match(/^\>/)) {
						is_removing = false;
					}
					
					if(!is_removing) {
						txt.push(line);
					}
				}
				
				$this.val(txt.join("\n"));
				$this.caret('pos', pos - 4);
			}
		});
		
		$frm.find('button.submit').click(function(e) {
			$.mobile.loading('show');
			
			$.post(
				'{devblocks_url}ajax.php{/devblocks_url}',
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