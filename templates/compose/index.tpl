<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-compose" data-theme="c" data-dom-cache="false">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">

	<form id="frm{$uniqid}" method="post">
	<input type="hidden" name="c" value="m">
	<input type="hidden" name="a" value="saveCompose">
	
	<h3>Compose</h3>

	<div data-role="fieldcontain">
		<label for="cerb-compose-from"> {'message.header.from'|devblocks_translate|capitalize}:</label>
		
		<div>
			<select name="group_id" id="cerb-compose-from" data-inline="true" data-mini="true">
				{foreach from=$groups item=group}
				<option value="{$group->id}">{$group->name}</option>
				{/foreach}
			</select>
			
			<select name="bucket_id" id="cerb-compose-bucket" data-inline="true" data-mini="true">
				<option value="0">{'common.inbox'|devblocks_translate|capitalize}</option>
				{$group_id = key($groups)}
				{foreach from=$buckets item=bucket}
				 {if $bucket->group_id == $group_id}
				<option value="{$bucket->id}">{$bucket->name}</option>
				{/if}
				{/foreach}
			</select>
		</div>
	</div>
	
	<div data-role="fieldcontain">
		<label for="cerb-compose-to"> {'message.header.to'|devblocks_translate|capitalize}:</label>
		<input type="text" name="to" id="cerb-compose-to" value="{$to}">
		<ul id="cerb-compose-to-autocomplete" class="cerb-ul-autocomplete" data-role="listview" data-inset="true" data-filter-theme="d" style="margin:0;"></ul>
	</div>
	
	<div data-role="fieldcontain">
		<label for="cerb-compose-subject"> {'message.header.subject'|devblocks_translate|capitalize}:</label>
		<input name="subject" id="cerb-compose-subject" placeholder="" value="" type="text">
	</div>
	
	<div data-role="fieldcontain">
		<label for="cerb-compose-body"> {'common.message'|devblocks_translate|capitalize}:</label>
		<textarea name="body" id="cerb-compose-body" placeholder=""></textarea>
		
		<div>
			<a href="javascript:;" class="cerb-compose-btn-insert-sig" data-role="button" data-mini="true" data-inline="true">{'display.reply.insert_sig'|devblocks_translate|capitalize}</a>
		</div>
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
	
	<button type="button" class="submit" data-inline="true" data-theme="b" class="ui-btn-hidden" aria-disabled="false">{'display.ui.send_message'|devblocks_translate|capitalize}</button>
	
	</form>
	
</div>

<script type="text/javascript">
$(document).one('pageinit', function() {
	var $frm = $('#frm{$uniqid}');

	$frm.find('select[name=group_id], select[name=bucket_id]').each(function() {
		$(this).closest('.ui-select').css('display', 'inline-block');
	});
	
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
	
	$frm.find('#cerb-compose-to').on('keyup', function(e) {
		clearTimeout(document.autocompleteComposeTimer);
		
		document.autocompleteComposeTimer = setTimeout(function() {
			$('#frm{$uniqid} #cerb-compose-to').trigger('cerbautocomplete');
		}, 500);
	});
	
	$frm.find('#cerb-compose-to').on('cerbautocomplete', function(e) {
		var $input = $(this);
		var val = $input.val();
		var $autocomplete = $frm.find('#cerb-compose-to-autocomplete');
		
		if(val.length == 0) {
			$autocomplete.html('');
			return;
		}
		
		// Split previous input at commas
		val = $.trim(val.split(',').slice(-1));
		
		// Ajax request
		$.get(
			'{devblocks_url}ajax.php?c=internal&a=autocomplete&context={CerberusContexts::CONTEXT_ADDRESS}&term={/devblocks_url}' + encodeURIComponent(val),
			function(out) {
				$autocomplete.html('');
				
				var json = $.parseJSON(out);
				
				if(typeof json == "object" && json.length > 0)
				for(i in json) {
					var label = $('<div/>').text(json[i].label).html();
					
					var $li = $('<li><a href="javascript:;" style="white-space:normal;word-wrap:break-word;word-break:break-word;" cerb-address-id="' + json[i].value + '">' + label + '</a></li>');
					
					$li.find('a').on('click', function() {
						var address_id = $(this).attr('cerb-address-id');
						var label = $(this).text();
						
						var addresses = $input.val().split(',');
						addresses.splice(-1);
						
						var previous_input = (addresses.length > 0) ? (addresses.join(',') + ', ') : ''; 
						
						$input.val(previous_input + label + ', ').focus();
						
						$autocomplete.html('');
					});
					
					$autocomplete.append($li);
				}
				
				$autocomplete.listview('refresh');
			}
		)
	});
	
	$frm.find('a.cerb-compose-btn-insert-sig').on('click', function(e) {
		var $frm = $(this).closest('form');
		var group_id = $frm.find('select[name=group_id]').val();
		var bucket_id = $frm.find('select[name=bucket_id]').val();
		
		$.get(
			'{devblocks_url}ajax.php{/devblocks_url}?c=tickets&a=getComposeSignature&group_id=' + group_id + '&bucket_id=' + bucket_id,
			function(out) {
				var $textarea = $frm.find('textarea[name=body]');
				$textarea.val($textarea.val() + "\n" + out);
				$textarea.trigger('change');
			}
		);
	});
	
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
	
	$frm.find('button.submit').click(function() {
		$.mobile.loading('show');
		
		$.post(
			'{devblocks_url}ajax.php{/devblocks_url}',
			$frm.serialize(),
			function(json) {
				if(undefined == json.success || !json.success)
					return;
				
				//window.history.go(-2);
				$.mobile.changePage(
					'{devblocks_url}c=m&a=profile&t={CerberusContexts::CONTEXT_TICKET}{/devblocks_url}/' + json.ticket_id,
					{
						transition: 'fade'
					}
				);
			}
		);
	});
});
</script>

</div><!-- /page -->

</body>
</html>

