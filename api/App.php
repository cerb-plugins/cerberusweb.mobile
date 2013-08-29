<?php
class Controller_Mobile extends DevblocksControllerExtension {
	function isVisible() {
		// The current session must be a logged-in worker to use this page.
		if(null == ($worker = CerberusApplication::getActiveWorker()))
			return false;
		return true;
	}

	/*
	 * Request Overload
	 */
	function handleRequest(DevblocksHttpRequest $request) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		// If we're not logged in, redirect to a login form
		if(empty($active_worker)) {
			$query = array();
			
			if(is_array($request->path) && !empty($request->path))
				$query = array('url'=> urlencode(implode('/',$request->path)));
			
			DevblocksPlatform::redirect(new DevblocksHttpRequest(array('login'), $query));
			exit;
		}
		
		$stack = $request->path;
		array_shift($stack); // example
		
		@$action = array_shift($stack) . 'Action';

		switch($action) {
			case NULL:
				// [TODO] Index/page render
				break;
				
			default:
				// Default action, call arg as a method suffixed with Action
				if(method_exists($this,$action)) {
					call_user_func(array(&$this, $action));
				}
				break;
		}
	}

	function writeResponse(DevblocksHttpResponse $response) {
		$stack = $response->path;
		
		@array_shift($stack); // m
		@$controller = array_shift($stack);
		
		////////////
		$tpl = DevblocksPlatform::getTemplateService();
		$translate = DevblocksPlatform::getTranslationService();
		$active_worker = CerberusApplication::getActiveWorker();
		$settings = DevblocksPlatform::getPluginSettingsService();
		
		$tpl->assign('active_worker', $active_worker);
		
		if($active_worker instanceof Model_Worker)
			$tpl->assign('active_worker_memberships', $active_worker->getMemberships());
		
		$tpl->assign('translate', $translate);
		$tpl->assign('settings', $settings);
		$tpl->assign('controller', $controller);
		
		$notification_count = DAO_Notification::getUnreadCountByWorker($active_worker->id);
		$tpl->assign('notification_count', $notification_count);
		////////////
		
		switch($controller) {
				
			default:
			case 'notifications':
				$this->_renderNotifications($stack);
				break;
				
			case 'va':
				@$request = array_shift($stack);
				
				if(is_numeric($request)) {
					array_unshift($stack, $request);
					$this->_renderVirtualAttendantBehaviors($stack);
					return;
				}
				
				switch($request) {
					case 'behavior':
						$this->_renderVirtualAttendantBehavior($stack);
						break;
					
					default:
						$this->_renderVirtualAttendants($stack);
						break;
				}
				
				break;
				
			case 'workspaces':
				$this->_renderWorkspaces($stack);
				break;
				
			case 'workspace':
				@$request = array_shift($stack);
				
				if(is_numeric($request)) {
					array_unshift($stack, $request);
					$this->_renderWorkspace($stack);
					return;
				}
				
				switch($request) {
					case 'tab':
						$this->_renderWorkspaceTab($stack);
						break;
						
					case 'worklist':
						$this->_renderWorkspaceList($stack);
						break;
						
					case 'widget':
						$this->_renderWorkspaceWidget($stack);
						break;
				}
				
				
				break;
		}
	}
	
	private function _renderNotifications($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$notifications = DAO_Notification::getWhere(sprintf("%s = %d AND %s = %d",
			DAO_Notification::WORKER_ID,
			$active_worker->id,
			DAO_Notification::IS_READ,
			0
		));
		
		$tpl->assign('notifications', $notifications);
		
		$tpl->display('devblocks:cerberusweb.mobile::notifications/index.tpl');
	}
	
	private function _renderWorkspaces($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$workspaces = DAO_WorkspacePage::getByWorker($active_worker);
		$tpl->assign('workspaces', $workspaces);
		
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/index.tpl');
	}
	
	private function _renderWorkspace($stack) {
		@$workspace_id = array_shift($stack);

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		$workspaces = DAO_WorkspacePage::getByWorker($active_worker);
		
		if(!isset($workspaces[$workspace_id]))
			return;
		
		$workspace_page = $workspaces[$workspace_id]; /* @var $workspace_page Model_WorkspacePage */
		$tpl->assign('workspace', $workspace_page);
		
		$workspace_tabs = $workspace_page->getTabs($active_worker);
		$tpl->assign('workspace_tabs', $workspace_tabs);
		
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/page.tpl');
	}
	
	private function _renderWorkspaceTab($stack) {
		@$workspace_tab_id = array_shift($stack);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		$workspace_tab = DAO_WorkspaceTab::get($workspace_tab_id);
		$tpl->assign('workspace_tab', $workspace_tab);
		
		$workspaces = DAO_WorkspacePage::getByWorker($active_worker);
		
		if(!isset($workspaces[$workspace_tab->workspace_page_id]))
			return;
		
		$workspace_page = $workspace_tab->getWorkspacePage();
		$tpl->assign('workspace_page', $workspace_page);

		$workspace_lists = DAO_WorkspaceList::getByTab($workspace_tab_id);
		$tpl->assign('workspace_lists', $workspace_lists);
		
		$workspace_widgets = DAO_WorkspaceWidget::getByTab($workspace_tab_id);
		$tpl->assign('workspace_widgets', $workspace_widgets);
		
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/tab.tpl');
	}
	
	private function _renderWorkspaceList($stack) {
		@$workspace_list_id = array_shift($stack);

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		$worklist = DAO_WorkspaceList::get($workspace_list_id);

		$view_id = 'cust_' . $worklist->id;
		
		// Make sure our workspace source has a valid renderer class
		if(null == ($ext = DevblocksPlatform::getExtension($worklist->context, true))) { /* @var $ext Extension_DevblocksContext */
			return;
		}
		
		if(null == ($view = C4_AbstractViewLoader::getView($view_id))) {
			$list_view = $worklist->list_view; /* @var $list_view Model_WorkspaceListView */
				
			$view = $ext->getChooserView($view_id);  /* @var $view C4_AbstractView */
				
			if(empty($view))
				return;
				
			$view->name = $list_view->title;
			$view->renderLimit = 10; //$list_view->num_rows;
			$view->renderPage = 0;
			$view->is_ephemeral = 0;
			$view->view_columns = $list_view->columns;
			$view->addParams($list_view->params, true);
			if(property_exists($list_view, 'params_required'))
				$view->addParamsRequired($list_view->params_required, true);
			$view->renderSortBy = $list_view->sort_by;
			$view->renderSortAsc = $list_view->sort_asc;
			$view->renderSubtotals = $list_view->subtotals;
		}
	
		if(!empty($view)) {
			$labels = array();
			$values = array();
				
			$labels['current_worker_id'] = array(
				'label' => 'Current Worker',
				'context' => CerberusContexts::CONTEXT_WORKER,
			);
				
			$values['current_worker_id'] = $active_worker->id;
	
			$view->setPlaceholderLabels($labels);
			$view->setPlaceholderValues($values);
				
			C4_AbstractViewLoader::setView($view_id, $view);
		}
		
		$view->renderPage = 0;
		$view->renderLimit = 25;
		
		$tpl->assign('view', $view);
		
		$workspace_tab = DAO_WorkspaceTab::get($worklist->workspace_tab_id);
		$tpl->assign('workspace_tab', $workspace_tab);
		
		$workspace_page = $workspace_tab->getWorkspacePage();
		$tpl->assign('workspace_page', $workspace_page);

		$tpl->display('devblocks:cerberusweb.mobile::workspaces/worklist.tpl');
	}
	
	private function _renderWorkspaceWidget($stack) {
		@$workspace_widget_id = array_shift($stack);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		$widget = DAO_WorkspaceWidget::get($workspace_widget_id);
		$tpl->assign('widget', $widget);
		
		$widget_extension = Extension_WorkspaceWidget::get($widget->extension_id);
		$tpl->assign('widget_extension', $widget_extension);
		
		$workspace_tab = DAO_WorkspaceTab::get($widget->workspace_tab_id);
		$tpl->assign('workspace_tab', $workspace_tab);
		
		$workspace_page = $workspace_tab->getWorkspacePage();
		$tpl->assign('workspace_page', $workspace_page);
		
		if($widget_extension->id == 'core.workspace.widget.worklist') {
			$view = $widget_extension->getView($widget);
			$view->renderLimit = 25;
			$tpl->assign('view', $view);
		}
		
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/widget.tpl');
	}
	
	/* Virtual Attendants */
	
	private function _renderVirtualAttendants($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$vas = DAO_VirtualAttendant::getReadableByActor($active_worker);
		
		// Only show VAs with mobile behaviors
		$vas = array_filter($vas, function($va) {
			$behaviors = $va->getBehaviors(Event_MobileBehavior::ID, false);
			return !empty($behaviors);
		});
		
		$tpl->assign('vas', $vas);
		
		$tpl->display('devblocks:cerberusweb.mobile::virtual_attendants/index.tpl');
	}
	
	private function _renderVirtualAttendantBehaviors($stack) {
		@$va_id = array_shift($stack);

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();

		$va = DAO_VirtualAttendant::get($va_id);
		
		if(!$va->isReadableByActor($active_worker))
			return;
		
		$tpl->assign('va', $va);
		
		$behaviors = $va->getBehaviors(Event_MobileBehavior::ID, false);
		$tpl->assign('behaviors', $behaviors);
		
		$tpl->display('devblocks:cerberusweb.mobile::virtual_attendants/behaviors.tpl');
	}
	
	private function _renderVirtualAttendantBehavior($stack) {
		@$behavior_id = array_shift($stack);

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		if(null == ($behavior = DAO_TriggerEvent::get($behavior_id)))
			return;
		
		if(null == ($va = $behavior->getVirtualAttendant()))
			return;
		
		if(!$va->isReadableByActor($active_worker))
			return;
		
		$tpl->assign('va', $va);
		$tpl->assign('behavior', $behavior);
		
		$tpl->display('devblocks:cerberusweb.mobile::virtual_attendants/behavior.tpl');
	}
	
	public function runVirtualAttendantBehaviorAction() {
		@$behavior_id = DevblocksPlatform::importGPC($_REQUEST['behavior_id'], 'integer', 0);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		if(false == ($behavior = DAO_TriggerEvent::get($behavior_id)))
			return false;
		
		if(false == ($va = $behavior->getVirtualAttendant()))
			return false;
		
		if(false == $va->isReadableByActor($active_worker))
			return false;
		
		if($va->is_disabled)
			return false;
		
		if($behavior->is_disabled)
			return false;

		$tpl->assign('va', $va);
		$tpl->assign('behavior', $behavior);
		
		// Vars

		$vars = array();
		
		if(is_array($behavior->variables)) {
			foreach($behavior->variables as $var_key => $var) {
				if(!empty($var['is_private']))
					continue;
				
				// Complain if we're not given all the public vars
				
				//if(!isset($_REQUEST[$var_key]))
					//return false;
					//$this->error(self::ERRNO_CUSTOM, sprintf("The public variable '%s' is required.", $var_key));
				
				
				// Format passed variables
				
				$var_val = null;
				
				try {
					if(isset($_REQUEST[$var_key]))
						@$var_val = $behavior->formatVariable($var, DevblocksPlatform::importGPC($_REQUEST[$var_key]));
					
					
				} catch(Exception $e) {
					//if(!isset($_REQUEST[$var_key]))
						//return false;
						//$this->error(self::ERRNO_CUSTOM, $e->getMessage());
					
				}
				
				$vars[$var_key] = $var_val;
			}
		}
		
		// [TODO] Verify the trigger is a mobile behavior (event.api.mobile_behavior)
		
		// Load event manifest
		if(null == ($ext = DevblocksPlatform::getExtension($behavior->event_point, false))) /* @var $ext DevblocksExtensionManifest */
			return false;
			//$this->error(self::ERRNO_CUSTOM);
		
		// Trigger a mobile behavior
		$runners = call_user_func(array($ext->class, 'trigger'), $behavior->id, $active_worker->id, $vars);
		
		$values = array();
		
		if(null != (@$runner = $runners[$behavior->id])) {
			// Return the whole scope of the behavior to the caller
			$values = $runner->getDictionary();
			//@$message = $runner->_output ?: ''; /* @var $runner DevblocksDictionaryDelegate */
		}

		$dict = new DevblocksDictionaryDelegate($values);
		
		$response = $dict->_response;
		$tpl->assign('response', $response);
		
		$tpl->display('devblocks:cerberusweb.mobile::virtual_attendants/run_behavior.tpl');
	}
};