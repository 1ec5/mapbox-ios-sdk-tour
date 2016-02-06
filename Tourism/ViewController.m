@import Mapbox;

#import "ViewController.h"

static const CLLocationCoordinate2D Destinations[] = {
    { 38.9131982, -77.0325453144239 },
    { 37.7757368, -122.4135302 },
    { 12.9810816, 77.6368034 },
    { -13.15589555, -74.2178961777998 },
};

@interface ViewController () <MGLMapViewDelegate>

@property (weak, nonatomic) IBOutlet MGLMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.showsUserLocation = YES;
}

- (IBAction)startTour:(id)sender {
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSUInteger numberOfAnnotations = sizeof(Destinations) / sizeof(Destinations[0]);
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:numberOfAnnotations];
    for (NSUInteger i = 0; i < numberOfAnnotations; i++) {
        MGLPointAnnotation *annotation = [[MGLPointAnnotation alloc] init];
        annotation.coordinate = Destinations[i];
        [annotations addObject:annotation];
    }
    [self.mapView addAnnotations:annotations];
    [self continueTourWithRemainingAnnotations:annotations];
}

- (void)continueTourWithRemainingAnnotations:(NSMutableArray<MGLPointAnnotation *> *)annotations {
    MGLPointAnnotation *nextAnnotation = annotations.firstObject;
    if (!nextAnnotation) {
        [self performSelector:@selector(startTour:)
                   withObject:self
                   afterDelay:5];
        return;
    }
    
    [annotations removeObjectAtIndex:0];
    MGLMapCamera *camera = [MGLMapCamera cameraLookingAtCenterCoordinate:nextAnnotation.coordinate
                                                            fromDistance:10
                                                                   pitch:arc4random_uniform(60)
                                                                 heading:arc4random_uniform(360)];
    __weak ViewController *weakSelf = self;
    [self.mapView flyToCamera:camera completionHandler:^{
        ViewController *strongSelf = weakSelf;
        [strongSelf performSelector:@selector(continueTourWithRemainingAnnotations:)
                         withObject:annotations
                         afterDelay:2];
    }];
}

- (void)mapViewWillStartLocatingUser:(MGLMapView *)mapView {
    [self startTour:self];
}

@end
