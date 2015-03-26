<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-compose" data-theme="a" data-dom-cache="false">

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
		
		<div style="color:rgb(120,120,120);">Use <b>#commands</b> to perform additional actions.</div>
		
		<div>
			<textarea name="body" id="cerb-compose-body" placeholder="">


#signature
#cut
</textarea>
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
	
	<button type="button" class="submit" data-inline="true" data-theme="a" class="ui-btn-hidden" aria-disabled="false">{'display.ui.send_message'|devblocks_translate|capitalize}</button>
	
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
	
	// Submit
	
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

