{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right">
	<div data-role="header" data-theme="b">
		<h1>Edit</h1>
	</div>
	
	<div data-role="content">
		<form id="frm{$uniqid}" method="post">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="handleProfileBlockRequest">
		<input type="hidden" name="extension" value="{MobileProfile_Task::ID}">
		<input type="hidden" name="action" value="saveEditDialog">
		<input type="hidden" name="id" value="{$dict->id}">

		<div data-role="fieldcontain">
			<label for="frm-cerb-task-edit-title"> {'task.title'|devblocks_translate}:</label>
			 
			<input type="text" name="title" id="frm-cerb-task-edit-title" value="{$dict->title}" />
		</div>
		
		<div data-role="fieldcontain">
			<fieldset data-role="controlgroup" data-type="horizontal" data-mini="true">
				<legend>Status:</legend>
				
				{$statuses = [active,completed]}
				
				{foreach from=$statuses item=status}
				<input type="radio" name="status" id="frm-cerb-task-status-{$status}" value="{$status}" {if $dict->status == $status}checked="checked"{/if}>
				<label for="frm-cerb-task-status-{$status}">{$status}</label>
				{/foreach}
			</fieldset>
		</div>

		<div data-role="fieldcontain" class="status-dependent status-active" {if in_array($dict->status,[active])}{else}style="display:none;"{/if}>
			<label for="frm-cerb-task-edit-due_date"> {'task.due_date'|devblocks_translate}:</label>
			 
			<input type="text" name="due_date" id="frm-cerb-task-edit-due_date" value="{$dict->due|devblocks_date}" />
		</div>
		
		<button data-role="button" type="button" class="submit" data-theme="b">{'common.save_changes'|devblocks_translate|capitalize}</button>
	</div>
	
	<script type="text/javascript">
		var $frm = $('#frm{$uniqid}');
		
		$frm.find('input:radio[name=status]').on('change', function(e) {
			var $frm = $(this).closest('form');
			$frm.find('div.status-dependent').hide();
			$frm.find('div.status-dependent.status-' + $(this).val()).show();
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
							'{devblocks_url}c=m&a=profile&t={CerberusContexts::CONTEXT_TASK}&id={$dict->id}{/devblocks_url}',
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