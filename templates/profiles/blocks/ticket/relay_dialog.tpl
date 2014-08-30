{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right" data-theme="a">
	<div data-role="header" data-theme="a">
		<h1>Relay</h1>
	</div>
	
	<div data-role="content">
		<form id="frm{$uniqid}" method="post">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="handleProfileBlockRequest">
		<input type="hidden" name="extension" value="{MobileProfile_Ticket::ID}">
		<input type="hidden" name="action" value="saveRelayDialog">
		<input type="hidden" name="message_id" value="{$dict->id}">

		<div data-role="fieldcontain" data-theme="a">
			<label for="frm-cerb-relay-to"> {'message.header.to'|devblocks_translate|capitalize}:</label>
			 
			<select name="emails[]" id="frm-cerb-relay-to" multiple="multiple" data-native-menu="false" data-divider-theme="f">
				<option>Choose recipients</option>
				{foreach from=$workers_with_relays item=worker key=worker_id}
					{if !empty($worker->relay_emails)}
						<optgroup label="{$worker->getName()}" data-theme="a">
							{foreach from=$worker->relay_emails item=relay}
							<option value="{$relay}">{$relay}</option>
							{/foreach}
						</optgroup>
					{/if}
				{/foreach}
			</select>
		</div>
		
		<div data-role="fieldcontain" data-theme="a">
			<label><input type="checkbox" id="frm-cerb-relay-include-files" name="include_attachments" value="1"> Include attachments</label>
		</div>
	
		<button data-role="button" type="button" class="submit" data-theme="b">Relay message</button>
	</div>
	
	<script type="text/javascript">
		var $frm = $('#frm{$uniqid}');
		
		$frm.find('button.submit').click(function(e) {
			$.mobile.loading('show');
			
			$.post(
				'{devblocks_url}ajax.php{/devblocks_url}',
				$frm.serialize(),
				function(json) {
					$.mobile.changePage(
						'{devblocks_url}c=m&a=profile&t={CerberusContexts::CONTEXT_TICKET}&id={$dict->ticket_id}{/devblocks_url}',
						{
							transition: 'fade',
							changeHash: false,
							reloadPage: true
						}
					);
				}
			);
		});
	</script>
</div>