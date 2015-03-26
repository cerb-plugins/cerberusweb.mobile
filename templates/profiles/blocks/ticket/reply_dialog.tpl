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

		{$group = DAO_Group::get($dict->ticket_group_id)} 
		<div>		
			<label> Message:</label>
			<div style="color:rgb(120,120,120);">Use <b>#commands</b> to perform additional actions.</div>
			<div>

{$signature_pos = DAO_WorkerPref::get($active_worker->id, 'mobile_mail_signature_pos', 2)}

{if 0 == $signature_pos}{* Signature disabled *}
<textarea name="content" id="frm-cerb-reply-content">On {$dict->created|devblocks_date:'D, d M Y'}, {$dict->sender__label} wrote:
{$dict->content|devblocks_email_quotes_cull|indent:1:'> '}
</textarea>
{elseif 1 == $signature_pos}{* Signature above *}
<textarea name="content" id="frm-cerb-reply-content">


#signature
#cut

On {$dict->created|devblocks_date:'D, d M Y'}, {$dict->sender__label} wrote:
{$dict->content|devblocks_email_quotes_cull|indent:1:'> '}</textarea>
{else}{* Signature below *}
<textarea name="content" id="frm-cerb-reply-content">On {$dict->created|devblocks_date:'D, d M Y'}, {$dict->sender__label} wrote:
{$dict->content|devblocks_email_quotes_cull|indent:1:'> '}


#signature
#cut
</textarea>
{/if}
			</div>
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

		// #commands and @mentions
		
		$frm.find('textarea').on('delete_quote_from_cursor', function(e) {
			var $this = $(this);
			var pos = $this.caret('pos');
			
			var lines = $this.val().split("\n");
			var txt = [];
			var is_removing = false;
			
			for(idx in lines) {
				var line = $.trim(lines[idx]);
				
				if(line == "#delete quote from here") {
					is_removing = true;
					continue;
				}
				
				if(is_removing && !line.match(/^\>/) && !line.match(/^On .* wrote:/)) {
					is_removing = false;
				}
				
				if(!is_removing) {
					txt.push(line);
				}
			}

			$this.val(txt.join("\n"));
			$this.caret('pos', pos - "#delete quote from here\n".length);
		});
		
		var atwho_file_bundles = {CerberusApplication::getFileBundleDictionaryJson() nofilter};
		var atwho_workers = {CerberusApplication::getAtMentionsWorkerDictionaryJson() nofilter};
		
		$frm.find('textarea')
			.atwho({
				at: '#attach ',
				{literal}tpl: '<li data-value="#attach ${tag}\n">${name} <small style="margin-left:10px;">${tag}</small></li>',{/literal}
				suffix: '',
				data: atwho_file_bundles,
				limit: 10
			})
			.atwho({
				at: '#',
				data: [
					'attach ',
					'comment',
					'comment @',
					'cut\n',
					'delete quote from here\n',
					'signature\n',
					'unwatch\n',
					'watch\n'
				],
				limit: 10,
				suffix: '',
				hide_without_suffix: true,
				callbacks: {
					before_insert: function(value, $li) {
						if(value.substr(-1) != '\n' && value.substr(-1) != '@')
							value += ' ';
						
						return value;
					}
				}
			})
			.atwho({
				at: '@',
				{literal}tpl: '<li data-value="@${at_mention}">${name} <small style="margin-left:10px;">${title}</small></li>',{/literal}
				data: atwho_workers,
				limit: 10
			})
			;
		
		$frm.find('textarea').on('inserted.atwho', function(event, $li) {
			if($li.text() == 'delete quote from here\n')
				$(this).trigger('delete_quote_from_cursor');
		});
		
		// Submit
		
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