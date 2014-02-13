{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right">
	<div data-role="header" data-theme="f">
		<h1>Edit</h1>
	</div>
	
	<div data-role="content">
		<h3 style="margin:0;white-space:normal;word-wrap:break-word;word-break:break-word;">{$dict->_label}</h3>
	
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
			<label for="frm-cerb-ticket-group"> {'common.group'|devblocks_translate|capitalize}:</label>
			
			<div>
				<select name="group_id" id="frm-cerb-ticket-group" data-inline="true" data-mini="true">
					{foreach from=$groups item=group}
					<option value="{$group->id}" {if $dict->group_id == $group->id}selected="selected"{/if}>{$group->name}</option>
					{/foreach}
				</select>
			</div>
		</div>
		
		<div data-role="fieldcontain" class="status-dependent status-open status-waiting status-closed" {if !in_array($dict->status,[deleted])}{else}style="display:none;"{/if}>
			<label for="frm-cerb-ticket-bucket"> {'common.bucket'|devblocks_translate|capitalize}:</label>
			
			<div>
				<select name="bucket_id" id="frm-cerb-ticket-bucket" data-inline="true" data-mini="true">
					<option value="0">{'common.inbox'|devblocks_translate|capitalize}</option>
					{$group_id = key($groups)}
					{foreach from=$buckets item=bucket}
					 {if $bucket->group_id == $dict->group_id}
					<option value="{$bucket->id}" {if $dict->bucket_id == $bucket->id}selected="selected"{/if}>{$bucket->name}</option>
					{/if}
					{/foreach}
				</select>
			</div>
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
		
		<button data-role="button" type="button" class="submit" data-theme="f">{'common.save_changes'|devblocks_translate|capitalize}</button>
	</div>
	
	<script type="text/javascript">
		var $frm = $('#frm{$uniqid}');
		
		$frm.find('select[name=group_id]').each(function() {
			var buckets = [];
			
			{foreach from=$buckets item=bucket}
			buckets.push({
				'id': {$bucket->id},
				'name': '{$bucket->name|escape:'javascript'}',
				'group_id': {$bucket->group_id},
			});
			{/foreach}
			
			$(this).jqmData('buckets', buckets);
		});
		
		$frm.find('select[name=group_id]').change(function() {
			var $frm = $(this).closest('form');
			var group_id = $(this).val();
			var buckets = $(this).jqmData('buckets');
			var $buckets = $frm.find('select[name=bucket_id]');
			
			$buckets.find('option').remove();
			
			if(group_id != 0)
				$buckets.append($('<option value="0">{'common.inbox'|devblocks_translate|capitalize|escape:'javascript'}</option>'));
			
			if(typeof buckets == 'object')
			for(idx in buckets) {
				if(buckets[idx].group_id == group_id)
					$buckets.append($('<option value="' + buckets[idx].id + '">' + buckets[idx].name + '</option>'));
			}
			
			$buckets.selectmenu('refresh');
		});
		
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
				'{devblocks_url}ajax.php{/devblocks_url}',
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