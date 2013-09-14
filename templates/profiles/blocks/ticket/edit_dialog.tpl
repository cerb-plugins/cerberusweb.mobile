{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right">
	<div data-role="header" data-theme="b">
		<h1>Edit</h1>
	</div>
	
	<div data-role="content">
		<form id="frm{$uniqid}" method="post">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="handleProfileBlockRequest">
		<input type="hidden" name="extension" value="{MobileProfile_Ticket::ID}">
		<input type="hidden" name="action" value="saveEditDialog">
		<input type="hidden" name="id" value="{$dict->id}">

		<div data-role="fieldcontain">
			<fieldset data-role="controlgroup" data-type="horizontal" data-mini="true">
				<legend>Status:</legend>
				
				{$statuses = [open,waiting,closed,deleted]}
				
				{foreach from=$statuses item=status}
				<input type="radio" name="status" id="frm-cerb-ticket-status-{$status}" value="{$status}" {if $dict->status == $status}checked="checked"{/if}>
				<label for="frm-cerb-ticket-status-{$status}">{$status}</label>
				{/foreach}
			</fieldset>
		</div>

		<div data-role="fieldcontain" class="status-dependent status-waiting status-closed" {if in_array($dict->status,[waiting,closed])}{else}style="display:none;"{/if}>
			<label for="frm-cerb-ticket-edit-reopen"> {'display.reply.next.resume'|devblocks_translate}</label>
			 
			<input type="text" name="reopen_at" id="frm-cerb-ticket-edit-reopen" value="{$dict->reopen_date|devblocks_date}" />
		</div>
		
		<div data-role="fieldcontain" class="status-dependent status-open status-waiting status-closed" {if !in_array($dict->status,[deleted])}{else}style="display:none;"{/if}>
			<label for="frm-cerb-ticket-edit-owner"> Owner:</label>
			
			<select name="owner_id" id="frm-cerb-ticket-edit-owner" data-mini="true">
				<option value="0">- {'common.nobody'|devblocks_translate|lower} -</option>
				{$workers = DAO_Worker::getAllActive()}
				{foreach from=$workers item=worker}
					<option value="{$worker->id}" {if $dict->owner_id == $worker->id}selected="selected"{/if}>{$worker->getName()}</option>
				{/foreach}
			</select>
		</div>
		
		{if empty($dict->spam_training)}
		<div data-role="fieldcontain" class="status-dependent status-open status-waiting status-closed" {if !in_array($dict->status,[deleted])}{else}style="display:none;"{/if}>
			<fieldset data-role="controlgroup" data-type="horizontal" data-mini="true">
				<legend>Spam training:</legend>
				
				<input type="radio" name="spam_training" id="frm-cerb-ticket-spam-training-na" value="" checked="checked">
				<label for="frm-cerb-ticket-spam-training-na">None</label>
				 
				<input type="radio" name="spam_training" id="frm-cerb-ticket-spam-training-spam" value="S">
				<label for="frm-cerb-ticket-spam-training-spam">Spam</label>
				 
				<input type="radio" name="spam_training" id="frm-cerb-ticket-spam-training-notspam" value="N">
				<label for="frm-cerb-ticket-spam-training-notspam">Not spam</label> 
			</fieldset>
		</div>
		{/if}
		
		<button data-role="button" type="button" class="submit" data-theme="b">{'common.save_changes'|devblocks_translate|capitalize}</button>
	</div>
	
	<script type="text/javascript">
		var $frm = $('#frm{$uniqid}');
		
		$frm.find('input:radio[name=status]').on('change', function(e) {
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
					
				case 'deleted':
					$frm.find('div.status-dependent.status-deleted').show();
					break;
			}
		});
		
		$frm.find('button.submit').click(function(e) {
			$.mobile.loading('show');
			
			$.post(
				'{devblocks_url}c=m{/devblocks_url}',
				$frm.serialize(),
				function(json) {
					if(json.success) {
						window.history.go(-1);
						$.mobile.changePage(
							'{devblocks_url}c=m&a=profile&t={CerberusContexts::CONTEXT_TICKET}&id={$dict->id}{/devblocks_url}',
							{
								allowSamePageTransition: true,
								transition: 'none',
								changeHash: false,
								showLoadMsg: true,
								reloadPage: true
							}
						);
					}
				}
			);
		});
	</script>
</div>