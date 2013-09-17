<?php
abstract class Extension_MobileProfileBlock extends DevblocksExtension {
	static function getAll($as_instances=false, $with_contexts=null) {
		if(!is_null($with_contexts) && !is_array($with_contexts))
			$with_contexts = array($with_contexts);
		
		$extensions = DevblocksPlatform::getExtensions('mobile.profile.block', true);
		
		if(is_array($with_contexts))
		foreach($extensions as $extension_id => $extension) {
			$allowed_contexts = array();
			
			if($as_instances) {
				$allowed_contexts = array_keys($extension->manifest->params['contexts'][0]);
			} else {
				$allowed_contexts = array_keys($extension->params['contexts'][0]);
			}
			
			foreach($with_contexts as $context) {
				if(!in_array($context, $allowed_contexts)) {
					unset($extensions[$extension_id]);
					continue;
				}
			}
		}
		
		return $extensions;
	}
	
	/**
	 * @param unknown_type $context
	 * @return Extension_DevblocksContext
	 */
	public static function get($id) {
		static $extensions = null;
		
		if(isset($extensions[$id]))
			return $extensions[$id];
		
		if(!isset($extensions[$id])) {
			if(null == ($ext = DevblocksPlatform::getExtension($id, true)))
				return;
			
			if(!($ext instanceof Extension_MobileProfileBlock))
				return;
			
			$extensions[$id] = $ext;
			return $ext;
		}
	}
	
	abstract function render(DevblocksDictionaryDelegate $dict);
};

if(class_exists('Extension_MobileProfileBlock')):
class MobileProfile_Calendar extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.calendar';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/calendar.tpl');
	}
	
	function calendarPageAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$month  = DevblocksPlatform::importGPC($_REQUEST['month'], 'integer', 0);
		@$year  = DevblocksPlatform::importGPC($_REQUEST['year'], 'integer', 0);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$visit = CerberusApplication::getVisit();
		$tpl = DevblocksPlatform::getTemplateService();
		
		$tpl->assign('month', $month);
		$tpl->assign('year', $year);
		
		CerberusContexts::getContext(CerberusContexts::CONTEXT_CALENDAR, $id, $labels, $values);
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Remember the month/year for this calendar
		$visit->set(sprintf('calendar_%d_monthyear', $id), array('month'=>$month, 'year'=>$year));
		
		$tpl->display('devblocks:cerberusweb.mobile::calendars/calendar.tpl');
	}
};

class MobileProfile_EmailAddress extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.email_address';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/address.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_ADDRESS, $id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/address/edit_dialog.tpl');
		exit;
	}
	
	function saveEditDialogAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$first_name = DevblocksPlatform::importGPC($_REQUEST['first_name'], 'string', '');
		@$last_name = DevblocksPlatform::importGPC($_REQUEST['last_name'], 'string', '');
		@$org_name = DevblocksPlatform::importGPC($_REQUEST['org'], 'string', '');
		@$is_banned = DevblocksPlatform::importGPC($_REQUEST['is_banned'], 'integer', 0);
		@$is_defunct = DevblocksPlatform::importGPC($_REQUEST['is_defunct'], 'integer', 0);
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$fields = array();
		
		// Fields
		
		$fields[DAO_Address::FIRST_NAME] = $first_name;
		$fields[DAO_Address::LAST_NAME] = $last_name;
		$fields[DAO_Address::IS_BANNED] = $is_banned;
		$fields[DAO_Address::IS_DEFUNCT] = $is_defunct;
		
		if(!empty($org_name) && false !== ($org_id = DAO_ContactOrg::lookup($org_name, true))) {
			if(false !== ($org = DAO_ContactOrg::get($org_id)))
				$fields[DAO_Address::CONTACT_ORG_ID] = $org_id;
		}
		
		// DAO
		
		DAO_Address::update($id, $fields);

		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
	
	function viewSearchTicketsAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		if(false == ($address = DAO_Address::get($id)))
			return;
		
		$context_ext = Extension_DevblocksContext::get(CerberusContexts::CONTEXT_TICKET);
		
		$view = $context_ext->getSearchView(); /* @var $view C4_AbstractView */
		
		$view->addParams(array(
			new DevblocksSearchCriteria(SearchFields_Ticket::REQUESTER_ADDRESS, '=', $address->email)
		), true);
		
		$view->renderSortBy = SearchFields_Ticket::TICKET_UPDATED_DATE;
		$view->renderSortAsc = false;
		
		C4_AbstractViewLoader::setView($view->id, $view);
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
	}
};

class MobileProfile_Message extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.message';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/message.tpl');
	}
};

class MobileProfile_Org extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.org';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/org.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_ORG, $id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/org/edit_dialog.tpl');
		exit;
	}
	
	function saveEditDialogAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$name = DevblocksPlatform::importGPC($_REQUEST['name'], 'string', '');
		@$street = DevblocksPlatform::importGPC($_REQUEST['street'], 'string', '');
		@$city = DevblocksPlatform::importGPC($_REQUEST['city'], 'string', '');
		@$province = DevblocksPlatform::importGPC($_REQUEST['province'], 'string', '');
		@$postal = DevblocksPlatform::importGPC($_REQUEST['postal'], 'string', '');
		@$country = DevblocksPlatform::importGPC($_REQUEST['country'], 'string', '');
		@$phone = DevblocksPlatform::importGPC($_REQUEST['phone'], 'string', '');
		@$website = DevblocksPlatform::importGPC($_REQUEST['website'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$fields = array();
		
		// Fields
		
		$fields[DAO_ContactOrg::NAME] = $name;
		$fields[DAO_ContactOrg::STREET] = $street;
		$fields[DAO_ContactOrg::CITY] = $city;
		$fields[DAO_ContactOrg::PROVINCE] = $province;
		$fields[DAO_ContactOrg::POSTAL] = $postal;
		$fields[DAO_ContactOrg::COUNTRY] = $country;
		$fields[DAO_ContactOrg::PHONE] = $phone;
		$fields[DAO_ContactOrg::WEBSITE] = $website;
		
		// DAO
		
		DAO_ContactOrg::update($id, $fields);

		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
	
	function viewSearchContactsAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		if(false == ($org = DAO_ContactOrg::get($id)))
			return;
		
		$context_ext = Extension_DevblocksContext::get(CerberusContexts::CONTEXT_ADDRESS);
		
		$view = $context_ext->getSearchView(); /* @var $view C4_AbstractView */
		
		$view->addParams(array(
			new DevblocksSearchCriteria(SearchFields_Address::ORG_NAME, '=', $org->name)
		), true);
		
		$view->renderSortBy = SearchFields_Address::NUM_NONSPAM;
		$view->renderSortAsc = false;
		
		C4_AbstractViewLoader::setView($view->id, $view);
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
	}
	
	function viewSearchTicketsAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		if(false == ($org = DAO_ContactOrg::get($id)))
			return;
				
		$context_ext = Extension_DevblocksContext::get(CerberusContexts::CONTEXT_TICKET);
		
		$view = $context_ext->getSearchView(); /* @var $view C4_AbstractView */
		
		$view->addParams(array(
			new DevblocksSearchCriteria(SearchFields_Ticket::ORG_NAME, '=', $org->name)
		), true);
		
		$view->renderSortBy = SearchFields_Ticket::TICKET_UPDATED_DATE;
		$view->renderSortAsc = false;
		
		C4_AbstractViewLoader::setView($view->id, $view);
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
	}
};

class MobileProfile_Task extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.task';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/task.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_TASK, $id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/task/edit_dialog.tpl');
		exit;
	}
	
	function saveEditDialogAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$title = DevblocksPlatform::importGPC($_REQUEST['title'], 'string', '');
		@$status = DevblocksPlatform::importGPC($_REQUEST['status'], 'string', '');
		@$due_date = DevblocksPlatform::importGPC($_REQUEST['due_date'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$fields = array();
		
		// Title
		
		if(!empty($title))
			$fields[DAO_Task::TITLE] = $title;
		
		// Status
		
		switch($status) {
			case 'active':
				$fields[DAO_Task::IS_COMPLETED] = 0;
				$fields[DAO_Task::COMPLETED_DATE] = 0;
				break;
				
			case 'completed':
				$fields[DAO_Task::IS_COMPLETED] = 1;
				$fields[DAO_Task::COMPLETED_DATE] = time();
				break;
		}
		
		// Due date
		
		$fields[DAO_Task::DUE_DATE] = intval(@strtotime($due_date));
		
		// DAO
		
		DAO_Task::update($id, $fields);

		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
};

class MobileProfile_Ticket extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.ticket';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		
		/*
		// Show ticket messages
		$defaults = new C4_AbstractViewModel();
		$defaults->id = '';
		$defaults->class_name = 'View_Message';
		$defaults->is_ephemeral = true;
		
		if(false != ($view = C4_AbstractViewLoader::getView('mobile_profile_ticket_messages', $defaults))) {
			$view->addParamsRequired(array(
				new DevblocksSearchCriteria(SearchFields_Message::TICKET_ID, '=', $dict->id)
			), true);
			
			$view->renderSortBy = SearchFields_Message::CREATED_DATE;
			$view->renderSortAsc = false;
			$view->renderPage = 0;
			$view->renderLimit = 10;
			$view->renderTotal = true;
			
			// [TODO] Overload the default properties for the messages worklist (e.g. no need to see ticket listed every time)
			
			C4_AbstractViewLoader::setView($view->id, $view);
			
			$tpl->assign('view', $view);
		}
		*/
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_TICKET, $id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket/edit_dialog.tpl');
		exit;
	}
	
	function saveEditDialogAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$reopen_at = DevblocksPlatform::importGPC($_REQUEST['reopen_at'], 'string', '');
		@$status = DevblocksPlatform::importGPC($_REQUEST['status'], 'string', '');
		@$owner_id = DevblocksPlatform::importGPC($_REQUEST['owner_id'], 'integer', 0);
		@$spam_training = DevblocksPlatform::importGPC($_REQUEST['spam_training'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$fields = array();
		
		// [TODO] Check permissions
		if($status == 'deleted') {
			$fields[DAO_Ticket::IS_WAITING] = 0;
			$fields[DAO_Ticket::IS_CLOSED] = 1;
			$fields[DAO_Ticket::IS_DELETED] = 1;
			$fields[DAO_Ticket::REOPEN_AT] = 0;
			
		} else {
			// Spam training
			if(!empty($spam_training)) {
				if($spam_training == 'S')
					CerberusBayes::markTicketAsSpam($id);
				elseif($spam_training == 'N')
					CerberusBayes::markTicketAsNotSpam($id);
			}
			
			// Owner
			$fields[DAO_Ticket::OWNER_ID] = $owner_id;
			
			// Status
			switch($status) {
				case 'open':
					$fields[DAO_Ticket::IS_WAITING] = 0;
					$fields[DAO_Ticket::IS_CLOSED] = 0;
					$fields[DAO_Ticket::IS_DELETED] = 0;
					$fields[DAO_Ticket::REOPEN_AT] = 0;
					break;
					
				case 'waiting':
					$fields[DAO_Ticket::IS_WAITING] = 1;
					$fields[DAO_Ticket::IS_CLOSED] = 0;
					$fields[DAO_Ticket::IS_DELETED] = 0;
					$fields[DAO_Ticket::REOPEN_AT] = intval(@strtotime($reopen_at));
					break;
					
				case 'closed':
					$fields[DAO_Ticket::IS_WAITING] = 0;
					$fields[DAO_Ticket::IS_CLOSED] = 1;
					$fields[DAO_Ticket::IS_DELETED] = 0;
					$fields[DAO_Ticket::REOPEN_AT] = intval(@strtotime($reopen_at));
					break;
			}
		}
		
		DAO_Ticket::update($id, $fields);

		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
	
	function showReplyDialogAction() {
		@$message_id  = DevblocksPlatform::importGPC($_REQUEST['message_id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_MESSAGE, $message_id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket/reply_dialog.tpl');
		exit;
	}
	
	function saveReplyDialogAction() {
		@$message_id = DevblocksPlatform::importGPC($_REQUEST['reply_to_message_id'], 'integer', 0);
		@$content = DevblocksPlatform::importGPC($_REQUEST['content'], 'string', '');
		@$reopen_at = DevblocksPlatform::importGPC($_REQUEST['reopen_at'], 'string', '');
		@$status = DevblocksPlatform::importGPC($_REQUEST['status'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$new_message_id = CerberusMail::sendTicketMessage(array(
			'message_id' => $message_id,
			'closed' => array_search($status, array('open','closed','waiting')),
			'ticket_reopen' => ($status != 'open') ? $reopen_at : 0,
			'content' => $content,
			'worker_id' => $active_worker->id,
		));
		
		$message = DAO_Message::get($new_message_id);
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
			'message_id' => $message->id,
			'ticket_id' => $message->ticket_id,
		));
		
		exit;
	}
	
	function viewSearchMessagesAction() {
		@$ticket_id = DevblocksPlatform::importGPC($_REQUEST['ticket_id'], 'integer', 0);
		
		$ticket = DAO_Ticket::get($ticket_id);
		
		$context_ext = Extension_DevblocksContext::get(CerberusContexts::CONTEXT_MESSAGE);
		$view = $context_ext->getSearchView(); /* @var $view C4_AbstractView */
		$view->addParams(array(
			new DevblocksSearchCriteria(SearchFields_Message::TICKET_MASK, '=', $ticket->mask)
		), true);
		
		C4_AbstractViewLoader::setView($view->id, $view);
	}
	
	function getMessageAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		CerberusContexts::getContext(CerberusContexts::CONTEXT_MESSAGE, $id, $labels, $values);
		$dict = new DevblocksDictionaryDelegate($values);
		
		$tpl->assign('dict', $dict);
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket/message.tpl');
		exit;
	}
	
};
endif;