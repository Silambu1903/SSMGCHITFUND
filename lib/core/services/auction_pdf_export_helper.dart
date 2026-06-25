import '../../data/models/auction_model.dart';
import '../../data/models/member_model.dart';
import '../../data/repositories/auction_repository.dart';
import '../../data/repositories/chit_repository.dart';
import '../../data/repositories/member_repository.dart';
import 'auction_pdf_service.dart';

/// Loads auction + related data and opens the Tamil receipt PDF.
class AuctionPdfExporter {
  AuctionPdfExporter._();

  static Future<void> exportAuctionReceipt({
    required AuctionModel auction,
    AuctionRepository? auctionRepo,
    ChitRepository? chitRepo,
  }) async {
    final auctions = auctionRepo ?? AuctionRepository();
    final chits = chitRepo ?? ChitRepository();

    MemberModel? winner;
    if (auction.winningMemberId != null) {
      winner =
          await MemberRepository().getMemberById(auction.winningMemberId!);
    }

    final chit = await chits.getChitById(auction.chitId);

    final chitAuctions =
        await auctions.getAuctions(chitId: auction.chitId);
    final previousBalance = chitAuctions
        .where((a) => a.auctionMonth < auction.auctionMonth)
        .fold<double>(0, (sum, a) => sum + (a.dividendPool ?? 0));

    var enriched = auction;
    if (auction.winnerName == null) {
      for (final row in chitAuctions) {
        if (row.id == auction.id) {
          enriched = row;
          break;
        }
      }
    }

    final data = AuctionPdfData(
      auction: enriched,
      chit: chit,
      winner: winner,
      previousChitBalance: previousBalance,
    );

    await AuctionPdfService.previewAndExport(data);
  }
}
