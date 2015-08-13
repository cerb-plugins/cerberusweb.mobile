{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right" data-theme="a">
	<div data-role="header" data-theme="a">
		<h1>{'common.comment'|devblocks_translate|capitalize}</h1>
	</div>
	
	<div data-role="content">
		<form id="frm{$uniqid}" method="post">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="saveProfileAddCommentDialog">
		<input type="hidden" name="context" value="{$context}">
		<input type="hidden" name="context_id" value="{$context_id}">
		<input type="hidden" name="_csrf_token" value="{$session.csrf_token}">

		<div data-role="fieldcontain">
			<label for="frm-cerb-comment-content"> {'common.comment'|devblocks_translate|capitalize}:</label>
			<textarea name="comment" id="frm-cerb-comment-content" placeholder="{'comment.notify.at_mention'|devblocks_translate}"></textarea>
		</div>
	
		<button data-role="button" type="button" class="submit" data-theme="b">Save comment</button>
	</div>
	
	<script type="text/javascript">
		var $frm = $('#frm{$uniqid}');
		var $textarea = $frm.find('textarea[name=comment]');
		
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
		
		// @mentions
		
		var atwho_workers = {CerberusApplication::getAtMentionsWorkerDictionaryJson() nofilter};

		$textarea.atwho({
			at: '@',
			{literal}displayTpl: '<li>${name} <small style="margin-left:10px;">${title}</small> <small style="margin-left:10px;">@${at_mention}</small></li>',{/literal}
			{literal}insertTpl: '@${at_mention}',{/literal}
			data: atwho_workers,
			searchKey: '_index',
			limit: 10
		});
	</script>
</div>