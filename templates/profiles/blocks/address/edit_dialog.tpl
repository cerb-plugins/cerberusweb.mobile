{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right">
	<div data-role="header" data-theme="a">
		<h1>Edit</h1>
	</div>
	
	<div data-role="content">
		<h3 style="margin:0;white-space:normal;word-wrap:break-word;word-break:break-word;">{$dict->_label}</h3>
	
		<form id="frm{$uniqid}" method="post">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="handleProfileBlockRequest">
		<input type="hidden" name="extension" value="{MobileProfile_EmailAddress::ID}">
		<input type="hidden" name="action" value="saveEditDialog">
		<input type="hidden" name="id" value="{$dict->id}">

		<div data-role="fieldcontain">
			<label for="frm-cerb-addy-edit-firstname"> {'address.first_name'|devblocks_translate}:</label>
			<input type="text" name="first_name" id="frm-cerb-addy-edit-firstname" value="{$dict->first_name}" />
		</div>
		
		<div data-role="fieldcontain">
			<label for="frm-cerb-addy-edit-lasttname"> {'address.last_name'|devblocks_translate}:</label>
			<input type="text" name="last_name" id="frm-cerb-addy-edit-lastname" value="{$dict->last_name}" />
		</div>
		
		<div data-role="fieldcontain">
			<label for="frm-cerb-addy-edit-org"> {'contact_org.name'|devblocks_translate|capitalize}:</label>
			<input type="text" name="org" id="frm-cerb-addy-edit-org" value="{$dict->org_name}">
			<ul id="frm-cerb-addy-edit-org-autocomplete" class="cerb-ul-autocomplete" data-role="listview" data-inset="true" data-filter-theme="d" style="margin:0;"></ul>
		</div>
		
		<div data-role="fieldcontain">
			<fieldset data-role="controlgroup" data-type="horizontal" data-mini="true">
				<legend>Is Banned:</legend>
				
				<input type="radio" name="is_banned" id="frm-cerb-addy-isbanned-no" value="0" {if !$dict->is_banned}checked="checked"{/if}>
				<label for="frm-cerb-addy-isbanned-no">{'common.no'|devblocks_translate|lower}</label>
				
				<input type="radio" name="is_banned" id="frm-cerb-addy-isbanned-yes" value="1" {if $dict->is_banned}checked="checked"{/if}>
				<label for="frm-cerb-addy-isbanned-yes">{'common.yes'|devblocks_translate|lower}</label>
			</fieldset>
		</div>
		
		<div data-role="fieldcontain">
			<fieldset data-role="controlgroup" data-type="horizontal" data-mini="true">
				<legend>Is Defunct:</legend>
				
				<input type="radio" name="is_defunct" id="frm-cerb-addy-isdefunct-no" value="0" {if !$dict->is_defunct}checked="checked"{/if}>
				<label for="frm-cerb-addy-isdefunct-no">{'common.no'|devblocks_translate|lower}</label>
				
				<input type="radio" name="is_defunct" id="frm-cerb-addy-isdefunct-yes" value="1" {if $dict->is_defunct}checked="checked"{/if}>
				<label for="frm-cerb-addy-isdefunct-yes">{'common.yes'|devblocks_translate|lower}</label>
			</fieldset>
		</div>
		
		<button data-role="button" type="button" class="submit" data-theme="a">{'common.save_changes'|devblocks_translate|capitalize}</button>
	</div>
	
	<script type="text/javascript">
		var $frm = $('#frm{$uniqid}');
		
		$frm.find('button.submit').click(function(e) {
			$.mobile.loading('show');
			
			$.post(
				'{devblocks_url}ajax.php{/devblocks_url}',
				$frm.serialize(),
				function(json) {
					if(json.success) {
						window.history.go(-1);
						$.mobile.changePage(
							'{devblocks_url}c=m&a=profile&t={CerberusContexts::CONTEXT_ADDRESS}&id={$dict->id}{/devblocks_url}',
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
		
		$frm.find('#frm-cerb-addy-edit-org').on('keyup', function(e) {
			clearTimeout(document.autocompleteOrgEditAddyTimer);
			
			document.autocompleteOrgEditAddyTimer = setTimeout(function() {
				$('#frm{$uniqid} #frm-cerb-addy-edit-org').trigger('cerbautocomplete');
			}, 500);
		});
		
		$frm.find('#frm-cerb-addy-edit-org').on('cerbautocomplete', function(e) {
			var $input = $(this);
			var val = $input.val();
			var $autocomplete = $frm.find('#frm-cerb-addy-edit-org-autocomplete');
			
			if(val.length == 0) {
				$autocomplete.html('');
				return;
			}
			
			// Ajax request
			$.get(
				'{devblocks_url}ajax.php?c=internal&a=autocomplete&context={CerberusContexts::CONTEXT_ORG}&term={/devblocks_url}' + encodeURIComponent(val),
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
							
							$input.val(label);
							$autocomplete.html('');
						});
						
						$autocomplete.append($li);
					}
					
					$autocomplete.listview('refresh');
				}
			)
		});
	</script>
</div>