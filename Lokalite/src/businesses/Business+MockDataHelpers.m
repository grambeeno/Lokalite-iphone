//
//  Business+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Business+MockDataHelpers.h"

#import "NSManagedObject+GeneralHelpers.h"

@implementation Business (MockDataHelpers)

//+ (NSArray *)generateMockFeaturedBusinessesInContext:
//    (NSManagedObjectContext *)context
//{
//    NSMutableArray *businesses = [NSMutableArray array];
//
//    Business *business = nil;
//
//    business = [Business createInstanceInContext:context];
//    [business setName:@"Big City Burrito"];
//    [business setPhone:@"720.565.2489"];
//    [business setAddress:@"2426 Arapahoe Avenue Boulder, CO 80302"];
//    [business setSummary:@"Fresh. Flavorful. Fierce. At Big City Burrito, you won’t find microwaves or freezers, and you won’t find everyday fast food, either. We pack your tortilla with everything you crave and nothing you don’t want. From carnitas to potatoes, every ingr..."];
//    [businesses addObject:business];
//
//    business = [Business createInstanceInContext:context];
//    [business setName:@"Boulder Kind Care"];
//    [business setPhone:@"720.235.4232"];
//    [business setAddress:@"2031 16th Street Boulder, CO 80302"];
//    [business setSummary:@"Boulder Kind Care is a medical marijuana center providing high quality medical cannabis and wellness services to Colorado Medical Marijuana cardholders. The medical marijuana we provide is locally grown and of the highest quality."];
//    [businesses addObject:business];
//
//    business = [Business createInstanceInContext:context];
//    [business setName:@"LA'AU'S Taco Shop"];
//    [business setPhone:@"720-287-5913"];
//    [business setAddress:@"1335 Broadway Boulder, CO, 80302"];
//    [business setSummary:@"We believe in challenging the status quo. We believe in thinking simply.\n\nOur products are hand made, simple in design, and fresh to order… and we just happen to make delicious"];
//    [businesses addObject:business];
//
//    business = [Business createInstanceInContext:context];
//    [business setName:@"Pizzeria da Lupo"];
//    [business setPhone:@"303-555-1212"];
//    [business setAddress:@"2525 Arapahoe Ave. Boulder, CO 80302"];
//    [business setSummary:@"Get Real. The recipe is simple. Pizzeria da Lupo serves delicious wood-fired pizza and seasonal dishes in a comfortable, unpretentious setting. Beer, wine, and spirits are available."];
//    [businesses addObject:business];
//
//    business = [Business createInstanceInContext:context];
//    [business setName:@"Hapa Sushi Grill & Sake Bar (The Hill)"];
//    [business setPhone:@"303-447-9883"];
//    [business setAddress:@"1220 Pennsylvania Ave. Boulder, CO 80302"];
//    [business setSummary:@"Hapa is Hawaiian for a harmonious blend of Asian and American cultures. Our food, like our name, reflects this dynamic combination of East and West. Traditional Japanese fare is altered and amplified to create a unique cuisine."];
//    [businesses addObject:business];
//
//    business = [Business createInstanceInContext:context];
//    [business setName:@"Boulder Outdoor Cinema"];
//    [business setPhone:@"303-447-9883"];
//    [business setAddress:@"1750 13th Street Boulder, CO 80302"];
//    [business setSummary:@"Since 1995, the Boulder Outdoor Cinema has established itself as a quintessential Boulder summer tradition with hundreds of patrons attending screenings each week. Every year we shoot to create lineups programmed to appeal to everyone, focusing on cult classics, comedies and family fare. We continue to rock our infamous pre-show entertainment including short films, local musicians, trivia contests and other live entertainment. Boulder Outdoor Cinema is located behind the Boulder Museum of Contemporary Art on 13th Street, near Central Park, in the heart of downtown Boulder. Bring your blankets and low-slung lawn chairs and join in on the fun!\nSeating: BRING YOUR CHAIR! We recommend low-back chairs but all types of seating are welcome. The first several rows are reserved for low-backs, so bring your beanbag and get the sweet seats. If you prefer a director’s-style chair, you may be asked to sit further back – all the better for the widescreen view. Sectionals, papa sans and the occasional fainting couch are expected – don’t let us down!\nTechnical Information: Our movies are shown in state of the art digital video projection on an 18’ by 30’ screen. Since we’re purists, we insist on wide screen format whenever possible. We are specially hosting a couple of Closed Caption Nights starting this year, to ensure all of our friends can enjoy the movie, but are happy to turn on captions any night – just ask anyone on staff.\nTickets: Tickets can be snagged at the gate starting at 7 p.m. the night of the show. We are a donation-based business, and suggest $5 for adults and $3 for kids 12 and under. We’ve been able to pay our film licenses, staff ourselves and occasionally upgrade our equipment through your generous donations throughout the years and we appreciate it. We literally could not do this without your support!"];
//    [businesses addObject:business];
//
//    return businesses;
//}
//
//+ (NSArray *)mockFeaturedBusinessesInContext:(NSManagedObjectContext *)context
//{
//    NSArray *businesses = [self findAllInContext:context];
//    return [businesses count] == 0 ?
//        [self generateMockFeaturedBusinesses] : businesses;
//}

@end
