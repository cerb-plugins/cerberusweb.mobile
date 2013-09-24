{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right" data-theme="c">
	<div data-role="header" data-theme="f">
		<h1>{'common.comment'|devblocks_translate|capitalize}</h1>
	</div>
	
	<div data-role="content">
		<form id="frm{$uniqid}" method="post">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="saveProfileAddCommentDialog">
		<input type="hidden" name="context" value="{$context}">
		<input type="hidden" name="context_id" value="{$context_id}">

		<div data-role="fieldcontain">
			<label for="frm-cerb-comment-content"> {'common.comment'|devblocks_translate|capitalize}:</label>
			<textarea name="comment" id="frm-cerb-comment-content"></textarea>
		</div>
	
		<div data-role="fieldcontain">
			<label for="frm-cerb-comment-notify"> {'common.notify_workers'|devblocks_translate|capitalize}:</label>
			 
			<select name="also_notify_worker_ids[]" id="frm-cerb-comment-notify" multiple="multiple" data-native-menu="false">
				<option>Choose workers</option>
				{foreach from=$workers item=worker key=worker_id}
				<option value="{$worker_id}">{$worker->getName()}</option>
				{/foreach}
			</select>
		</div>
		
		<button data-role="button" type="button" class="submit" data-theme="f">Send message</button>
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
							'{devblocks_url}c=m&a=profile&ctx={$context}&id={$context_id}{/devblocks_url}',
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