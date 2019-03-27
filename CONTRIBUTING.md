# Contributing to Unwrap

There are lots of ways you can help build this app, and everyone is welcome regardless of skill level and experience. 

I already included suggestions for new contributors in the README.md, so here I want to walk you through the way the app is structured to help you understand how it fits together.


## Before you begin…

Make sure you also read and understand LICENSE.md. There is also a code of conduct in CODE_OF_CONDUCT.md that helps ensure contributions take place in a harassment-free environment.

If you have questions about the code, about making commits, or even if you’re not sure how to open pull requests to get your code merged, that’s OK – just tweet me [@twostraws](https://twitter.com/twostraws) and I’ll try to help. Everyone is welcome here, even if it’s their first time working in a team project.


## Tools

Unwrap was built using Xcode 10.2 and Swift 5.0.

The project uses SwiftLint, so please check all its tests pass when you make a change. You may need to install CocoaPods if you need to re-install the pods for some reason. Broadly speaking it’s preferable that you don’t upgrade pod versions just for fun – if there’s some particular feature or improvement that’s worthwhile let’s talk it over first.

Unwrap uses a *lot* of JSON – you should bookmark something like <https://jsonformatter.org> so you can check your JSON is correct easily. Annoyingly, JSON does not allow real line breaks in strings (they are encoded as `\n`), or comments. So, be prepared to read some fairly long strings in JSON! 


## Overview

The main app is split into five tabs: Home, Learn, Practice, Challenges, and News. These are all stored in the Activities group in the Xcode project, along with other discrete sections of the app.

All five app tabs have the same basic parts: a coordinator that handles navigation inside that tab (see the Navigation section that comes next), plus a main view controller that users see when they visit the tab. These will be named following the tab they are under, so look for HomeCoordinator and HomeViewController, for example.

Some of these tab groups have more groups inside them. For example, Home also contains the Help group because that’s where it’s stored in the app, and Practice includes one group for each type of practice the user can do.

After the Activities group you’ll find Extensions, which contain app-wide extensions to common types. There are quite a few of these, split up roughly by what they do, but the most important ones are:

- **BundleLoading.swift** includes methods and initializers for various types that load content directly from the bundle. For example, `Data`, `String`, `UIImage` and `UIColor` all contain `bundleName:` initializers that retrieve content from the bundle or crash on failure. Loading from the bundle should never fail, so this helps stop accidental typos.
- **String-Attributed.swift** includes a handful of methods for converting `String` to `NSAttributedString`. These are useful when you have minimal markup to parse, or when doing syntax highlighting.
- **String-Placeholders.swift** turns code strings with special placeholders, such as `RANDOM_STRING_VALUE_0`, into finished code. This is used to randomize the code in Predict the Output and Tap to Code so the user isn’t always faced with exactly the same code.
- **String-Variables.swift** turns a string of code into a string of homogenized code through a process of anonymization.  This is used in the Free Coding practice so that minor differences in code – did they use `var` when they could have used `let`? Did they name their struct `Bike` rather than `Bicycle`? – are ignored.
- **UIButton-Types.swift** contains default styling for the buttons in the app: primary and secondary buttons, plus methods that color them as correct and wrong as needed.
- **UITableViewCell-Styling.swift** contains the same sort of theming for table view cells.
- **UIViewController-Alert.swift** sets up the blue alerts you’ll see regularly in the app.

After Extensions comes Protocols, but there isn’t a lot in there – it’s mostly just protocol definitions or very small default implementations.

One important protocol is `UserTracking`. It doesn’t do much – it’s used to notify view controllers to refresh their data when the user completes a task – but it is used in lots of places.

The other important protocol is `Storyboarded`, which provides an `instantiate()` method for view controllers. This is used to create almost every view controller in the app: you call it directly on the class, and it gets created from the storyboard.

The main potentially confusing part is the way some basic behavior is defined using protocols: `AnswerHandling`, `Sequenced`, and `Skippable` are all used to handle various practice activities. They are pulled out like this because practice activities are used in the Practice tab (where answering/skipping one moves to another of the same type) and in the Challenges tab (where answering/skipping one moves to a different practice type.)

There’s a method called `titleSuffix(for: Sequenced)`, which returns what should be placed in the navigation item title, e.g. “1/5”, “1/10”, or something else.

Moving on, the `Reusables` group stores a a handful of reusable components such as `UIView` and `UIViewController` subclasses. These are used generally throughout the app, such as a view that draws gradients, and a view controller that shows alert messages.

The `User` group contains three files, all of which combine together to make the `User` class. This is a singleton because there can only ever be one user, and it’s shared across the app. This class is split into three files mainly to make it easier to understand – this one class handles everything to do with user data, so there’s a lot to it.

Finally, outside all the groups, is the main tab bar controller responsible for setting up the coordinators in each of its five tabs. You’ll also see Unwrap.swift, which is a tiny enum containing some static constants that are used throughout the app.


## Navigation

Unwrap uses the coordinator pattern to keep navigation code out of view controllers. If you haven’t used this pattern before, this tutorial ought to help: [How to use the coordinator pattern in iOS apps](https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps).

At its core, this means the vast majority of app navigation – i.e., moving from one view controller to another – takes place outside of view controllers. View controllers don’t know what screen comes next or came before, and shouldn’t need to. When screen A is finished what it’s doing it reports that to the coordinator, which then instantiates, configures, and presents screen B.

This approach allows Unwrap to use the same practice activities in two very different places: once using the practice coordinator, and once using the challenges coordinator. Each practice activity tells its coordinator that an answer was submitted, and it’s down to the coordinator to decide what to do next.

It’s the job of coordinators to manage the flow inside the application, so ideally all displaying of view controllers ought to be handled there. For the most part, view controllers are there to respond to view lifecycle events (`viewDidLoad()` and so on), plus handling user interaction.


## Home

I want to go into detail on the key parts of each app tab, starting with Home – the one users see when the app launches. This is mainly responsible for showing a single table view that provides details of the user’s learning progress so far: how many points they have, what rank they are, and what badges they have unlocked.

This table includes two important parts: a `StatusView` that renders their current rank image and a progress ring around it, and a `BadgeCollectionViewCell` that embeds a collection view inside the table view.

The `StatusView` was originally implemented using a simple `CAShapeLayer` for drawing the activity ring, but that has a problem: because this same `StatusView` is used when awarding points, it’s likely that the user will score more points than necessary to advance to the next rank. Using a `CAShapeLayer` doesn’t allow us to render the activity ring beyond 100%, so this now uses `MKRingProgressView`.

The collection view is used as a single row in the table so that we can show badges in a free-flowing grid. This causes a little complexity because we need to make `BadgeTableViewCell` conform to `UserTracking` so that badges appear unlocked as soon as they are earned, but it’s nothing difficult.

You’ll notice that responsibility for handling the table view’s data source is taken over by a separate class, `HomeDataSource`. This allows `HomeViewController` to focus on what remains, which isn’t much. 

**Note:** I have to admit to being a bit lazy with `HomeDataSource` – the whole thing should really be refactored to half its size.


## Learn

The Learn tab is responsible for teaching Swift, and has four main parts: showing all chapters, reading/watching a single section from Swift in Sixty Seconds, showing a postscript message with an additional nugget of information, and then letting users review what they learned.

There are a few points of interest here:

1. A checkmark is placed next to each chapter title in `LearnViewController`, regardless of whether they have completed it. The checkmark is different colors if they have read or review the chapter, or invisible if they’ve done neither, but it’s always at least present to ensure the titles are aligned neatly.
2. The actual reading page is an attributed string with an image at the top, all parsed from HTML.
3. When the user finishes reading, they are brought to one of two review screens: Single Select or Multiple Select. In the former they are shown some code and must select either True or False, and in the latter they are shown some code or answers and must tap all the rows that are correct.


## Practice

The Practice tab is by far the most complex, mostly because it encompasses multiple very different practice activities. These do have some things in common, though:

1. They all must have some type that conforms to `PracticeActivity`, which describes how they look for the main table view controller, and is also responsible for creating an instance of the correct view controller. These will have a name that ends with “Practice”, e.g. `TapToQuestion`.
2. Most are loaded from JSON, so you’ll see types that end with “Question” – e.g. `SpotTheErrorQuestion` and `PredictTheOutputQuestion` – that represent a single item loaded from the JSON.
3. All are locked until the user has read a particular chapter of the book; this is stored the practice activity’s `lockedUntil` property.

Let’s dive in to each of the practice activities…


### Free Coding

This is by far the most complex of all the practice activities – I’m only putting it first because this list of alphabetical!

This activity sets users a challenge – “here’s an array of numbers, write code to double them” – then allows them to write whatever code they want to solve that challenge. 

The reason this is difficult is because even a simple problem like doubling an array of numbers can be solved in a variety of ways using a variety of coding styles, and without the ability to compile Swift locally we can’t cover every case – it’s trivial to concoct example code that is valid but won’t pass the test. (And no, I don’t want to evaluate the code on a remote server.)

So, this activity tries to accept a selection of answers using three approaches:

1. Each question has several possible answers attached, each solving the problem in a different but valid way. If the user attempts something else, it won’t be accepted regardless of the following two steps.
2. All code gets anonymized then homogenized. This means variable names, function names, parameter names are all replaced with placeholders. Once that’s done code is homogenized so that it has a uniform style: all excess whitespace is removed, all brace positioning is standardized to `} else {` (as opposed to two or even three lines), shorthand data types are preferred (e.g. `[String]` rather than `Array<String>`, and so on.
3. The entire thing is then converted into a huge regular expression that allows explicit types to be used or not, allows whitespace around brackets, parentheses, commas, and colons, and allows users to use `var` when `let` was used in the answer.

The output of this process is *not* valid Swift code, but it allows us to accept tens of thousands of variations on our handful of sample answers – users can write whatever is their natural code style, and as long as their general approach is matched by one of our answers it will work.

There is a lot of scope for contribution here, all without touching the main Swift code for the app – if you look through FreeCoding.json and can think up a reasonable solution to a question that isn’t already present, add it!


## Predict the Output

This is the second most complicated practice activity – sorry!

This practice activity shows users some code, and asks them to enter what the program will output when it’s run. 

There are four reasons this is difficult:

- To add some variety to the code, it is gently randomized each time so that users won’t see the same code twice.
- Sometimes you’ll see filters that modify the code at runtime. These are a pipe symbol followed by a filter name, such as `|capitalized` to capitalize a string.
- Each question can have several answers depending on what comes up in the code. Remember, the code is randomized, so conditions based on random values might be true or false. So, each answer has a set of conditions that decide whether the answer is correct. Conditions are read in the order they appear, so you can make the final answer have no conditions.
- Those conditions are sometimes simple, such as measuring the length of a string, but sometimes they are mathematical. To resolve the latter in a neat way, JavaScriptCore is used: we send the expression directly there to be evaluated, and read the result back.

When working with this section, you’ll immediately see lots of placeholders such as `CONSTANT_OR_VARIABLE` and `RANDOM_STRING_NAME_0`. These are the randomization elements, and there are several of them:

- `CONSTANT_OR_VARIABLE` will become either `let` or `var`, because it doesn’t matter which is used.
- `RANDOM_STRING_NAME` generates a random variable name for a string, such as `favoriteColor`.
- `RANDOM_INT_NAME` generates a random variable name for an integer, such as `age`.
- `RANDOM_STRING_VALUE_0` generates an *appropriate* value for the first call to `RANDOM_STRING_NAME`. So, if the first `RANDOM_STRING_NAME` became `favoriteColor`, then `RANDOM_STRING_VALUE_0` might become “red”. You can use `RANDOM_STRING_VALUE_0` several times to get different appropriate values. You should adjust the 0 at the end relative to the random variable name you want to use.
- `NAME_0` becomes whatever variable name was created by the first `RANDOM_STRING_NAME` – it means “use the one we already made rather than making a new one.”
- `NAME_NATURAL_0` takes the variable name made in `RANDOM_STRING_NAME` – e.g. `favoriteColor` and makes it read naturally. In this case, that means “favorite color”.
- `RANDOM_OPERATOR` generates a random comparison operator: `<`, `>`, `<=`, `>=`, `==`, or `!=`.

There are also several filters:

- `count` sends back to the length of a string.
- `capitalized` capitalizes each word in a string, so that “hello world” becomes “Hello World”.
- `capitalizedFirst` capitalizes only the first letter in a string, so that “hello world” becomes “Hello world”.

Again, there’s a lot of scope for contribution here: I’ve written only a handful of examples in PredictTheOutput.json, mostly to make sure the code generation system works as I hoped. You’re most welcome to contribute more!

However, be careful: once you get the hang of it these things are easy to make, but at first the use of placeholders will hurt your brain! The best place to start is to copy an existing example and expand it.


### Rearrange the Lines

This is a nice and easy practice activity: we load some prewritten code, shuffle it up, and ask users to put it back in the correct order.

The only real complexity here is that some lines of code – specifically things like `}` or `} else {` – might appear several times in the same code, and there is no way of telling which is which. To avoid this problem entirely, when checking answers all leading whitespace is removed and the code is converted to a string, which means any lone closing brace can be used anywhere.

This one should be easy to write new examples for, but please make sure there is only *one* solution to each problem. This means there should be no ambiguity as to the order in which each line of code must appear.


## Spot the Error

This practice activity reads some example code and inserts one small error that users must identify.

This might sound trivial, but in all seriousness we need to be extraordinarily careful so that the error is presented clearly. As a result, it reads one of 12 different code samples (with randomization elements inside to keep users on their toes!), each with its own specific structure:

- It starts by defining a function that accepts an integer parameter and returns a string.
- That function must be called as the final line of code.
- It creates a constant or variable called `RETURN_NAME` that is explicitly marked as a string, and returned at the end of the function.
- It uses `+=` to add something to the return value.

Because those rules are adhered to strictly, this activity can apply many different kinds of transformations that break the code in subtle ways:

- Sometimes the function name is lowercased when called.
- Sometimes the function says it returns nothing.
- Sometimes the return value is marked as an integer.
- Sometimes anonymous parameters are used.
- And many more.

Each code sample is stored in its own file, largely because I found JSON’s lack of line break support too hard to work with here. 

Once you understand how these things are structured, it should be fairly straightforward to add new examples of your own.


### Tap to Code

This is a practice activity that shows a jumbled up series of code parts and asks users to arrange them correctly.

In theory this is easy; however, in practice, using drag and drop complicates things. Although a fair chunk of boilerplate code is required, it’s valuable, as it allows the user to change his or her mind without needing to remove and re-add lots of items.

To make this a little easier to follow, I’ve split the core of the implementation into two parts: `TapToCodeDataSource` is responsible for all the collection view drag and drop shenanigans, whereas `TapToCodeModel` handles all the underlying data.

Broadly you’re not going to want to touch the drag and drop implementation because it’s all very standard, but TapToCode.json has many opportunities for adding new examples. This uses the same code randomization placeholders as Predict the Output, so you should refer to the documentation above for what they do.


### Type Checker

This practice activity asks users to pick all variables and constants in a table that match a certain type, such as integers.

This is probably the simplest of all the practice activities, particularly because it doesn’t load anything from JSON – it’s all generated in code.

Most of the work here is done using a series of extensions that are stored in the Extensions > TypeGeneration group. These extensions generate random instances of various Swift data types, each time using appropriate data for that type – strings have things like names and addresses, integers have things like ages, days, and points.

So, to generate the answers for this activity we shuffle up all possible type generators, use the first one as our correct answer, and use a selection of the others for wrong answers.

If you’re looking to extend this, perhaps we could make it generate more complex data types like arrays, sets, and dictionaries. Ideally these extra features would be unlocked only when the user has completed the “Creating empty collections” chapter, to avoid them being confused.


## Challenges

Now that you understand how the various practice activities work, the Challenges tab is fairly simple: users may take part in one daily challenge per day, with each challenge made up of a random selection of practice activities.

These activities automatically know how to report completion because the challenges coordinator adopts the same protocols as the practice coordinator.


## News

This tab downloads news highlights from <https://www.hackingwithswift.com>, loading it into a table view. The only vaguely surprising thing here is that I’ve used SDWebImage to handle image fetching and caching.


## Awards

This group contains the view controller responsible for awarding points to the user. This can be triggered in four ways: when they have read a chapter, when they have reviewed a chapter (completed the short test after reading), when they have completed a practice activity, and when they have completed a daily challenge.

The code here is mainly responsible for showing the points being awarded – it uses the same `StatusView` rings as the home screen, and uses a `UILabel` subclass called `CountingLabel` so that users can see the points being awarded. The actual point awards, saving the changes, and notifying other parts of the app are all done by the `User` class.


## Assets

Unwrap includes a lot of content to provide a rich experience. This content comes in several forms:

- The Swift in Sixty Seconds content (all the reading and video material in Content > Sixty Seconds) is shipped as HTML, MP4 videos, and PNG video previews. The HTML has a very specific formatting, because it’s designed to be read into an `NSAttributedString`.
- Each Swift in Sixty Seconds chapter has an accompanying JSON file, describing a review test the user can take to solidify their knowledge.
- There are also separate JSON files responsible for various practice activities, such as RearrangeTheLines.json and TapToCode.json. These are stored alongside their Swift code.
- Asset catalogs containing images and colors.

**Please note:** There are several asset catalogs to help keep everything organized.

- **Assets** stores assets for use by iOS, which right now is just the app icon.
- **Colors** stores all named colors for use throughout the app. It is strongly preferred to use named colors everywhere to ensure consistency.
- **FontAwesomeIcons** stores all icons taken from the Font Awesome collection. These have a specific license attached to them, so it’s helpful to keep them in one place.
- **Ranks** stores the various images used for the rank levels.
- **Tour** stores the artwork used in the introductory tour. These are mostly screenshots, so are bitmap images.

Almost every piece of artwork in the app is stored as a PDF with Preserve Vector Data checked so we can use it at any size. Please do *not* add bitmap images unless you’ve discussed it with me first.


## Code style

I don’t have a documented code style, but you can figure things out just by reading all the existing code. If you follow the rule of writing new code in the same style as existing code, you should be fine.

That being said, there are some things you should be aware of:

1. Please make sure you always run SwiftLint before committing code. This will help you avoid the most common mistakes. Unless you want to see warnings in the CocoaPods (spoiler: you do not), make sure you run this inside the inner Unwrap directory.
2. If you make any UI changes, please make sure they are all Dynamic Type aware and accessibility enabled. Even using color can be problematic as a result of color blindness, so Unwrap often adds icons as well as colors.
3. I make extensive use of `fatalError()` and `assert()` for conditions that must never happen. This helps simplify code because we no longer need to do dummy unwraps of content.
4. When loading content from the bundle, please use your type’s `bundleName:` initializer, e.g. `UIImage(bundleName:)` or `String(bundleName:)`. This does most of the work for you, including adding a `fatalError()` if the bundle cannot be read.


## Before you commit code…

Contributors are very welcome, and I’ve tried to include a range of suggestions for things you can try both here and in the README.md file. However, before you commit any code please make sure you have at least done the following:

1. Run SwiftLint to make sure you fix any major styling errors.
2. Run all the tests and make sure they pass.
3. Document your changes using code comments.

It is strongly preferable that you also run Instruments to make sure your code is leak-free and performant, but if you’re less experienced that’s OK – add `// FIXME` markers to your code so that someone else can look at it later, then mention it in your pull request.
