<div id="cerb-footer" data-theme="b" data-role="footer" data-id="cerb-footer" data-position="fixed" data-tap-toggle="false">
	<div data-role="navbar" data-iconpos="top">
		<ul>
			<li>
				<a id="footer-notifications" href="{devblocks_url}c=m&a=notifications{/devblocks_url}" data-transition="fade" data-icon="custom" class="ui-nodisc-icon">
					{'common.notifications'|devblocks_translate|capitalize}
					<div class="ui-icon-cerb-badge-count{if $notification_count} nonzero{/if}">
						{$notification_count|default:'0'}
					</div>
				</a>
			</li>
			<li>
				<a id="footer-workspaces" href="{devblocks_url}c=m&a=workspaces{/devblocks_url}" data-transition="fade" data-icon="custom" class="ui-nodisc-icon">
					{'common.workspaces'|devblocks_translate|capitalize}
				</a>
			</li>
			<li>
				<a id="footer-vas" href="{devblocks_url}c=m&a=va{/devblocks_url}" data-transition="fade" data-icon="custom" class="ui-nodisc-icon">
					{'common.bots'|devblocks_translate|capitalize}
				</a>
			</li>
		</ul>
	</div>
</div>

<script type="text/javascript">
// Update the footer on all cached pages
$(function() {
$.mobile.pageContainer.find('.ui-footer .ui-icon-cerb-badge-count')
	.text('{$notification_count}')
	{if $notification_count}.addClass('nonzero'){else}.removeClass('nonzero'){/if}
	;
});
</script>