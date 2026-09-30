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
		'button2'
	],
	#category : 'Daedalus-Daedalus-Examples',
	#package : 'Daedalus',
	#tag : 'Daedalus-Examples'
}

{ #category : 'layout' }
DdTestPresenter >> defaultLayout [

	^ SpBoxLayout new
		  spacing: 10;
		  add: titleLabel height: 26;
		  add: agreeCheckBox height: 35;
		  add: listPresenter height: 65;
		  add: genderGroup height: 53;
		  add: nameInputPresenter expand: false;
		  add: hobbyGroup height: 49;
		  add: submitButton expand: false;
		  yourself
]

{ #category : 'initialization' }
DdTestPresenter >> initializePresenters [

	super initializePresenters.
	button2 := PresenterDecorator wrap: SpButtonPresenter.
	list1 := PresenterDecorator wrap: SpListPresenter.
	label1 := PresenterDecorator wrap: SpLabelPresenter.
	checkbox1 := PresenterDecorator wrap: SpCheckBoxPresenter.
	button1 := PresenterDecorator wrap: SpButtonPresenter.
	button1 height: 20.
	button1 backgroundColor: '#red'.
	button1 label: 'Hello!'.
	checkBox := SpCheckBoxPresenter new.
	checkBox label: 'Check'.
	titleLabel := LabelPresenter new.
	titleLabel label: 'Test form'.
	submitButton := ButtonPresenter new.
	submitButton label: 'Submit'.
	nameInputPresenter := TextInputPresenter new.
	nameInputPresenter text: 'Olesia'.
	nameInputPresenter placeholder: 'Enter your name'.
	date := PresenterDecorator wrap: SpDatePresenter.
	date date: '20 June 2026'.
	agreeCheckBox := CheckboxPresenter new.
	agreeCheckBox
		fontSize: 11;
		state: true;
		label: 'I agree'.
	genderGroup := RadioGroupPresenter new.
	genderGroup itemSelected: 2.
	genderGroup items: #( 'male' 'female' 'other' ).
	genderGroup showFrame: false.
	genderGroup showTitle: false.
	genderGroup сolumnCount: 3.
	genderGroup title: 'Gender'.
	genderGroup
		itemSelected: 2;
		showFrame: false;
		showTitle: true;
		title: 'Gender';
		items: #( 'male' 'female' 'other' );
		сolumnCount: 3.
	listPresenter := ListPresenter new.
	listPresenter items: #( '1' '2' '3' '5' '6' '7' '4' ).
	hobbyGroup := CheckboxGroupPresenter new.
	hobbyGroup selectedIndexes: #( 1 2 ).
	hobbyGroup items: #( 'Cooking' 'Traveling' 'Programming'
	   'Running' ).
	hobbyGroup showFrame: false.
	hobbyGroup showTitle: true.
	hobbyGroup сolumnCount: 2.
	hobbyGroup title: 'Hobby'.
	hobbyGroup
		items: #( 'Cooking' 'Traveling' 'Programming' 'Running' );
		selectedIndexes: #( 1 2 );
		showFrame: false;
		showTitle: false;
		сolumnCount: 2;
		title: 'Hobby'
]
