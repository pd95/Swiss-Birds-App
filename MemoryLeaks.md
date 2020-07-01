# Memory leaks/cycles in Swiss Birds

## State 30/06/2020

| NR | STATE | MEMORY ISSUES | Add | Malloc blocks | OBSERVATIONS |
| -- | ----- | ------------- | --- | ------------- | ------------ | 
| 1  | Showing the "Bird of the day" | 9 | 9 | 116 | All issues related to `Combine` and `AppState.checkBirdOfTheDay`. | 
| 2  | Scrolling to the bottom of the bird list | 9 | 0 | 2461 | no new issues |
| 3  | Scrolling back to the top of the bird list | 9 | 0 | 2654 | no new issues |
| 4  | Showing detail of first bird (1 image + voice load) | 15 | 6 | 2712 | Caused by `BirdDetailViewModel.fetchData` |
| 5  | Playing/Pausing the voice | 15 | 0 | 2713 | no new issues |
| 6  | Navigating back and again to the same bird | 15 | 0 | 2686 | no new issues |
| 7  | Navigating to the second bird | 49 | 34 | 2746 | Many complex retain cycles caused through combine | 
| 8  | Navigating to the third bird | 49 | 0 | 2775 | no new issues | 
| 9  | Navigating to the 4th bird | 15 | -34 | 2740 | Many retain cycles have resolved | 

## State 01/07/2020
| NR | STATE | MEMORY ISSUES | Add | Malloc blocks | OBSERVATIONS |
| -- | ----- | ------------- | --- | ------------- | ------------ | 
| 1  | Showing the "Bird of the day" | 8 | 8 | 13 | All issues related to `Combine` and `AppState.checkBirdOfTheDay`. | 
| 2  | Scrolling to the bottom of the bird list | 8 | 0 | 12 | no new issues |
| 3  | Scrolling back to the top of the bird list | 8 | 0 | 12 | no new issues |
| 4  | Showing detail of first bird (1 image + voice load) | 13 | 4 | 22 | Caused somehow `Combine` usage in `BirdDetailViewModel` |
| 5  | Playing/Pausing the voice | 13 | 0 | 23 | no new issues |
| 6  | Navigating back and again to the same bird | 13 | 0 | 33 | no new issues |
| 7  | Navigating to the second bird | 13 | 0 | 33 | no new issues | 
| 8  | Navigating to the third bird | 13 | 0 | 32 | no new issues | 
| 9  | Navigating to the 4th bird | 13 | 0 | 33 | no new issues| 


## State 01/07/2020 (Work in progress)
| NR | STATE | MEMORY ISSUES | Add | Malloc blocks | OBSERVATIONS |
| -- | ----- | ------------- | --- | ------------- | ------------ | 
| 1  | Showing the "Bird of the day" | 8 | 8 | 13 | All issues related to `Combine` and `AppState.checkBirdOfTheDay`. | 
| 2  | Scrolling to the bottom of the bird list | 8 | 0 | 13 | no new issues |
| 3  | Scrolling back to the top of the bird list | 8 | 0 | 13 | no new issues |
| 4  | Showing detail of first bird (1 image + voice load) | 13 | 4 | 23 | Caused somehow `Combine` usage in `BirdDetailViewModel` |
| 5  | Playing/Pausing the voice | 13 | 0 | 23 | no new issues |
| 6  | Navigating back and again to the same bird | 13 | 0 | 33 | no new issues |
| 7  | Navigating to the second bird | 13 | 0 | 33 | no new issues | 
| 8  | Navigating to the third bird | 13 | 0 | 32 | no new issues | 
| 9  | Navigating to the 4th bird | 13 | 0 | 33 | no new issues| 