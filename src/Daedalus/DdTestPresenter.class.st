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
		'checkBox'
	],
	#category : 'Daedalus-Daedalus-Examples',
	#package : 'Daedalus',
	#tag : 'Daedalus-Examples'
}

{ #category : 'layout' }
DdTestPresenter >> defaultLayout [

	| tmp1 |
	tmp1 := SpBoxLayout new.
	tmp1
		spacing: 10;
		add: titleLabel expand: false;
		add: nameInputPresenter expand: false;
		add: agreeCheckBox expand: false;
		add: hobbyGroup expand: false;
		add: listPresenter expand: true;
		add: genderGroup expand: false;
		add: submitButton expand: false.
	^ tmp1 yourself
]

{ #category : 'initialization' }
DdTestPresenter >> initializePresenters [
	super initializePresenters.
	checkBox := SpCheckBoxPresenter new.
	checkBox label: 'Check'.
	titleLabel := LabelPresenter new.
	titleLabel label: 'Test form'.
	submitButton := ButtonPresenter new.
	submitButton label: 'Submit'.
	nameInputPresenter := TextInputPresenter new.
	nameInputPresenter placeholder: 'Enter your name'.
	date := PresenterDecorator wrap: SpDatePresenter.
	date date: '20 June 2026'.
	agreeCheckBox := CheckboxPresenter new.
	agreeCheckBox
		fontSize: 11;
		state: true;
		label: 'I agree'.
	genderGroup := RadioGroupPresenter new.
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
	hobbyGroup
		items: #( 'Cooking' 'Traveling' 'Programming' 'Running' );
		selectedIndexes: #( 1 2 );
		showFrame: false;
		showTitle: false;
		сolumnCount: 2;
		title: 'Hobby'
]
