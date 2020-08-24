use lastmile_lms;

drop table if exists lastmile_lms.household;
drop table if exists lastmile_lms.HouseholdMembers;
drop table if exists lastmile_lms.female;
drop table if exists lastmile_lms.BirthHistoryOfRespondent;
drop table if exists lastmile_lms.child;
drop table if exists lastmile_lms.general;

create table lastmile_lms.household (

meta_UUID		                varchar( 255 ),
meta_autoDate		            varchar( 100 ),
meta_dataEntry_startTime		varchar( 100 ),
meta_dataEntry_endTime		  varchar( 100 ),
meta_dataSource		          varchar( 100 ),
meta_formVersion		        varchar( 100 ),
meta_deviceID		            varchar( 100 ),
meta_insert_date_time       datetime,

LinkUUID		                varchar( 255 ),

HouseholdID_Generated		    varchar( 100 ),
EnumeratorID		            varchar( 100 ),
ClusterID		                varchar( 100 ),
CommName		                varchar( 100 ),
TodayDate		                varchar( 100 ),
SurveyLanguage		          varchar( 100 ),
OtherLanguage		            varchar( 100 ),
NumberOfHouseholdMember		  varchar( 100 ),
FarmLandOwner		            varchar( 100 ),
NumberOfLaps		            varchar( 100 ),
SourceOfDrinkingWater		    varchar( 100 ),
ToiletPlace		              varchar( 100 ),
SharedToliet		            varchar( 100 ),
HouseholdBasicNeed		      varchar( 100 ),
CookingFuel		              varchar( 100 ),
SourceOfCurrentInHouse		  varchar( 100 ),
HouseFloorMaterial		      varchar( 100 ),
OtherFloorMaterialSpecify   varchar( 100 ),
HouseRoofMaterial		        varchar( 100 ),
HouseExteriorMaterial		    varchar( 100 ),
NumberOfBedroomInHouse		  varchar( 100 ),
MaterialOwner		            varchar( 100 ),
OwnAnimals		              varchar( 100 ),
NumberOfCows		            varchar( 100 ),
NumberOfPigs		            varchar( 100 ),
NumbrOfGoats		            varchar( 100 ),
NumberOfSheep		            varchar( 100 ),
NumberOfChickenDucks		    varchar( 100 ),
BankingMoney		            varchar( 100 )



)
;