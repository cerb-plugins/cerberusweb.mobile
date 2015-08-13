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
		<input type="hidden" name="extension" value="{MobileProfile_Org::ID}">
		<input type="hidden" name="action" value="saveEditDialog">
		<input type="hidden" name="id" value="{$dict->id}">
		<input type="hidden" name="_csrf_token" value="{$session.csrf_token}">

		<div data-role="fieldcontain">
			<label for="frm-cerb-org-edit-name"> {'common.name'|devblocks_translate}:</label>
			<input type="text" name="name" id="frm-cerb-org-edit-name" value="{$dict->name}" />
		</div>
		
		<div data-role="fieldcontain">
			<label for="frm-cerb-org-edit-street"> {"contact_org.street"|devblocks_translate}:</label>
			<textarea name="street" id="frm-cerb-org-edit-street" value="{$dict->street}"></textarea>
		</div>
		
		{$fields = [city,province,postal,country,phone,website]}
		
		{foreach from=$fields item=field}
		<div data-role="fieldcontain">
			<label for="frm-cerb-org-edit-{$field}"> {"contact_org.{$field}"|devblocks_translate}:</label>
			<input type="text" name="{$field}" id="frm-cerb-org-edit-{$field}" value="{$dict->$field}" />
		</div>
		{/foreach}
		
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
							'{devblocks_url}c=m&a=profile&t={CerberusContexts::CONTEXT_ORG}&id={$dict->id}{/devblocks_url}',
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