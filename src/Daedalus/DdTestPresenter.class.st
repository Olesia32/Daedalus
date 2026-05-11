Class {
	#name : 'DdTestPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'submitButton',
		'nameInput',
		'agreeCheckbox',
		'genderGroup',
		'hobyGroup',
		'prioritySlider',
		'progressBar',
		'combobox',
		'date',
		'time'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'layout' }
DdTestPresenter >> defaultLayout [

	^ SpBoxLayout new
		  spacing: 10;
		  add: titleLabel expand: false;
		  add: nameInput expand: true;
		  add: combobox expand: false;
		  add: agreeCheckbox expand: false;
		  add: genderGroup expand: false;
		  add: hobyGroup expand: false;
		  add: time expand: false;
		  add: submitButton expand: false;
		  yourself
]

{ #category : 'initialization' }
DdTestPresenter >> initializePresenters [

	super initializePresenters.

	titleLabel := LabelPresenter new.
	titleLabel label: 'Test form'.

	submitButton := ButtonPresenter new.
	submitButton label: 'Submit'.

	nameInput := TextInputPresenter new.
	nameInput text: 'Olesiа'.
	nameInput placeholder: 'Enter your name'.

	combobox := ComboBoxPresenter new.
	combobox selectIndex: 3.
	combobox items: #( 'Apple' 'Banana' 'Cherry' 'Orange' ).

	date := PresenterDecorator wrap: SpDatePresenter.
	date date: '20 June 2026'.

	agreeCheckbox := CheckboxPresenter new.
	agreeCheckbox state: false.
	agreeCheckbox label: 'I agree'.

	genderGroup := RadioGroupPresenter new.
	genderGroup itemSelected: 1.
	genderGroup showFrame: false.
	genderGroup showTitle: true.
	genderGroup title: 'Gender'.
	genderGroup items: #( 'male' 'female' 'other' ).
	genderGroup сolumnCount: 1.

	hobyGroup := CheckboxGroupPresenter new.
	hobyGroup items: #('Cooking' 'Traveling' 'Reading' 'Programming').
	hobyGroup showFrame: false.
	hobyGroup showTitle: true.
	hobyGroup сolumnCount: 2.
	hobyGroup title: 'Hobby'.
	hobyGroup
		items: #( 'Cooking' 'Traveling' 'Reading' 'Programming' );
		сolumnCount: 2;
		title: 'Hobby'.
	prioritySlider := PresenterDecorator wrap: SpSliderPresenter.
	prioritySlider quantum: 3.
	prioritySlider label: 'Slider'.
	prioritySlider value: 100.
	prioritySlider max: 200.
	prioritySlider min: 5.

	time := TimePickerPresenter new.

	progressBar := PresenterDecorator wrap: SpProgressBarPresenter.
	titleLabel fontSize: 12.
	agreeCheckbox fontSize: 12.
	agreeCheckbox color: '#green'
]
