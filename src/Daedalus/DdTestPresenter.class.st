Class {
	#name : 'DdTestPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'submitButton',
		'genderGroup',
		'date',
		'listPresenter',
		'hobbyGroup',
		'nameInputPresenter',
		'agreeCheckBox',
		'checkBox',
		'button1',
		'checkbox1',
		'label1',
		'list1',
		'button2',
		'datepicker1',
		'textarea1',
		'timepicker1',
		'timepicker2',
		'combobox1',
		'slider1',
		'progressbar1',
		'textinput1',
		'textinput2',
		'label2',
		'groupofradiobuttons1',
		'textinput3',
		'groupofcheckboxes1',
		'groupofradiobuttons2',
		'textinput4',
		'datepicker2',
		'combobox2',
		'textinput5',
		'groupofcheckboxes2',
		'timepicker3',
		'dontSaveButton',
		'birthDatePicker',
		'birthDateLabel',
		'emailInput',
		'emailLabel',
		'button3',
		'registerButton',
		'termsCheckbox',
		'passwordInput',
		'passwordCaptionLabel',
		'emailCaptionLabel',
		'fullNameInput',
		'nameCaptionLabel'
	],
	#category : 'Daedalus-Daedalus-Examples',
	#package : 'Daedalus',
	#tag : 'Daedalus-Examples'
}

{ #category : 'layout' }
DdTestPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  vAlignCenter;
		  spacing: 15;
		  borderWidth: 25;
		  add: (SpBoxLayout newLeftToRight
				   hAlignCenter;
				   add: titleLabel expand: false;
				   yourself)
		  expand: false
		  fill: false
		  padding: 0;
		  add: nameCaptionLabel
		  expand: false
		  fill: false
		  padding: 0;
		  add: fullNameInput height: 35;
		  add: emailCaptionLabel
		  expand: false
		  fill: false
		  padding: 0;
		  add: emailInput height: 35;
		  add: passwordCaptionLabel
		  expand: false
		  fill: false
		  padding: 0;
		  add: passwordInput height: 35;
		  add: termsCheckbox
		  expand: false
		  fill: false
		  padding: 5;
		  add: (SpBoxLayout newLeftToRight
				   hAlignCenter;
				   add: registerButton;
				   yourself)
		  height: 40;
		  yourself
]

{ #category : 'initialization' }
DdTestPresenter >> initializePresenters [

	super initializePresenters.
	nameCaptionLabel := PresenterDecorator wrap: SpLabelPresenter.
	nameCaptionLabel bold.
	nameCaptionLabel label: 'Повне ім''я'.
	nameCaptionLabel color: '#4A3B5C'.
	fullNameInput := PresenterDecorator wrap: TextInputPresenter.
	fullNameInput placeholder: 'Введіть ваше ім''я'.
	fullNameInput backgroundColor: '#F7F5FA'.
	fullNameInput borderColor: '#D1C4E9'.
	fullNameInput borderWidth: 1.
	emailCaptionLabel := PresenterDecorator wrap: SpLabelPresenter.
	emailCaptionLabel bold.
	emailCaptionLabel label: 'Електронна пошта'.
	emailCaptionLabel color: '#4A3B5C'.
	passwordCaptionLabel := PresenterDecorator wrap: SpLabelPresenter.
	passwordCaptionLabel bold.
	passwordCaptionLabel label: 'Пароль'.
	passwordCaptionLabel color: '#4A3B5C'.
	passwordInput := PresenterDecorator wrap: TextInputPresenter.
	passwordInput placeholder: '••••••••'.
	passwordInput backgroundColor: '#F7F5FA'.
	passwordInput borderColor: '#D1C4E9'.
	passwordInput borderWidth: 1.
	termsCheckbox := PresenterDecorator wrap: SpCheckBoxPresenter.
	termsCheckbox label: 'Погоджуюсь з умовами використання'.
	termsCheckbox state: false.
	registerButton := PresenterDecorator wrap: SpButtonPresenter.
	registerButton bold.
	registerButton label: 'Створити акаунт'.
	registerButton color: '#FFFFFF'.
	registerButton backgroundColor: '#9575CD'.
	registerButton width: 200.
	registerButton height: 40.
	button3 := PresenterDecorator wrap: SpButtonPresenter.
	emailLabel := PresenterDecorator wrap: SpLabelPresenter.
	emailLabel label: 'Email'.
	emailInput := PresenterDecorator wrap: TextInputPresenter.
	emailInput backgroundColor: '#F7F5FA'.
	emailInput borderColor: '#D1C4E9'.
	emailInput borderWidth: 1.
	emailInput placeholder: 'example@domain.com'.
	birthDateLabel := PresenterDecorator wrap: SpLabelPresenter.
	birthDateLabel label: 'Дата народження'.
	birthDatePicker := PresenterDecorator wrap: SpDatePresenter.
	birthDatePicker date: ''.
	dontSaveButton := PresenterDecorator wrap: SpButtonPresenter.
	dontSaveButton label: 'Don’t save'.
	timepicker3 := PresenterDecorator wrap: TimePickerPresenter.
	groupofcheckboxes2 := PresenterDecorator wrap: CheckboxGroupPresenter.
	textinput5 := PresenterDecorator wrap: TextInputPresenter.
	combobox2 := PresenterDecorator wrap: ComboBoxPresenter.
	datepicker2 := PresenterDecorator wrap: SpDatePresenter.
	textinput4 := PresenterDecorator wrap: TextInputPresenter.
	groupofradiobuttons2 := PresenterDecorator wrap: RadioGroupPresenter.
	groupofcheckboxes1 := PresenterDecorator wrap: CheckboxGroupPresenter.
	textinput3 := PresenterDecorator wrap: TextInputPresenter.
	groupofradiobuttons1 := PresenterDecorator wrap: RadioGroupPresenter.
	label2 := PresenterDecorator wrap: SpLabelPresenter.
	textinput2 := PresenterDecorator wrap: TextInputPresenter.
	textinput1 := PresenterDecorator wrap: TextInputPresenter.
	progressbar1 := PresenterDecorator wrap: SpProgressBarPresenter.
	slider1 := PresenterDecorator wrap: SpSliderPresenter.
	combobox1 := PresenterDecorator wrap: ComboBoxPresenter.
	timepicker2 := PresenterDecorator wrap: TimePickerPresenter.
	timepicker1 := PresenterDecorator wrap: TimePickerPresenter.
	textarea1 := PresenterDecorator wrap: SpTextPresenter.
	datepicker1 := PresenterDecorator wrap: SpDatePresenter.
	button2 := PresenterDecorator wrap: SpButtonPresenter.
	list1 := PresenterDecorator wrap: SpListPresenter.
	label1 := PresenterDecorator wrap: SpLabelPresenter.
	checkbox1 := PresenterDecorator wrap: SpCheckBoxPresenter.
	button1 := PresenterDecorator wrap: SpButtonPresenter.
	button1
		height: 20;
		backgroundColor: '#red';
		label: 'Hello!'.
	checkBox := SpCheckBoxPresenter new.
	checkBox label: 'Check'.
	titleLabel := LabelPresenter new.
	titleLabel bold.
	titleLabel fontSize: 24.
	titleLabel color: '#4A3B5C'.
	titleLabel label: 'Реєстрація'.
	submitButton := ButtonPresenter new.
	submitButton color: '#FFFFFF'.
	submitButton backgroundColor: '#673AB7'.
	submitButton bold.
	submitButton label: 'Надіслати'.
	nameInputPresenter := TextInputPresenter new.
	nameInputPresenter
		text: 'Olesia';
		placeholder: 'Enter your name'.
	date := PresenterDecorator wrap: SpDatePresenter.
	date date: '20 June 2026'.
	agreeCheckBox := CheckboxPresenter new.
	agreeCheckBox
		state: true;
		fontSize: 11;
		label: 'Я погоджуюся';
		fontSize: 11;
		state: true;
		label: 'Я погоджуюся'.
	genderGroup := RadioGroupPresenter new.
	genderGroup columnCount: 2.
	genderGroup
		itemSelected: 1;
		items: #( 'чоловіча' 'жіноча' 'інша' );
		showFrame: false;
		showTitle: true;
		columnCount: 2;
		title: 'Стать';
		itemSelected: 1;
		showFrame: false;
		showTitle: true;
		title: 'Стать';
		items: #( 'чоловіча' 'жіноча' 'інша' );
		columnCount: 2.
	listPresenter := ListPresenter new.
	listPresenter items: #( '1' '3' '6' '7' '4' '8' '13' ).
	hobbyGroup := CheckboxGroupPresenter new.
	hobbyGroup columnCount: 2.
	hobbyGroup
		selectedIndexes: #( 1 2 3 );
		items: #( 'Готування' 'Подорожі' 'Біг' );
		showFrame: false;
		showTitle: false;
		columnCount: 2;
		title: 'Хобі';
		items: #( 'Готування' 'Подорожі' 'Біг' );
		selectedIndexes: #( 1 2 3 );
		showFrame: false;
		showTitle: false;
		columnCount: 2;
		title: 'Хобі'
]
