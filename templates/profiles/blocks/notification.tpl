{if $dict->assignee_id == $active_worker->id && !$dict->is_read}
<a href="javascript:;" data-role="button" class="cerb-profile-notification-markread">Mark as read</a>

<script type="text/javascript">
$(document).one('pagebeforeshow', function() {
	$.mobile.activePage.find('a.cerb-profile-notification-markread').on('click', function() {
		$.post(
			'{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Notification::ID}&action=markRead&id={$dict->id}{/devblocks_url}',
			function(out) {
				$('#page-notifications').remove();
				$('#page-search-context').remove();
				
				window.history.back();
			}
		);
	});
});
</script>
{/if}
